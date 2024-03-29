import Combine
import Foundation
import Network
import OSLog

private let logger = Logger(category: "VISCAConnection")

extension NWConnection.State: CustomStringConvertible {
	public var description: String {
		switch self {
		case .setup:
			return "setup"
		case .waiting:
			return "waiting"
		case .preparing:
			return "preparing"
		case .ready:
			return "ready"
		case .failed:
			return "failed"
		case .cancelled:
			return "cancelled"
		@unknown default:
			return "unknown"
		}
	}
}

final class VISCAConnection {
	enum Error: Swift.Error, LocalizedError {
		case invalidInitialResponseByte
		case unexpectedBytes
		case missingAck
		case missingCompletion
		case syntaxError
		case notExecutable
		case notReady
		case timeout
		case commandInProgress
		case requestInProgress
		case connectionClosed

		var errorDescription: String? {
			switch self {
			case .invalidInitialResponseByte:
				"Received an invalid response from the camera."
			case .unexpectedBytes:
				"Received unexpected data from the camera."
			case .missingAck:
				"The camera did not respond."
			case .missingCompletion:
				"The camera did not respond after updating."
			case .notReady:
				"The camera is not connected."
			case .timeout:
				"The operation timed out."
			case .commandInProgress:
				"Command already in progress."
			case .requestInProgress:
				"Request already in progress."
			case .syntaxError:
				"Something went wrong."
			case .notExecutable:
				"The camera does not support this feature."
			case .connectionClosed:
				"The connection was closed."
			}
		}
	}

	private var observers: Set<AnyCancellable> = []

	private let connection: NWConnection
	let connectionNumber: Int

	var didCancel: ((VISCAConnection) -> Void)?
	var didExecute: ((VISCAConnection) -> Void)?
	var didCompleteCommand: ((VISCAConnection) -> Void)?

	enum State: Equatable {
		static func == (lhs: VISCAConnection.State, rhs: VISCAConnection.State) -> Bool {
			switch (lhs, rhs) {
			case (.notReady, .notReady):
				true
			case (.connecting, .connecting):
				true
			case (.ready, .ready):
				true
			case (.failed, .failed):
				true
			default:
				false
			}
		}

		case notReady
		case connecting
		case ready
		case failed(Swift.Error)
	}

	// Published fires before the value is set, which is problematic
	let state = CurrentValueSubject<State, Never>(.notReady)

	init(host: NWEndpoint.Host, port: NWEndpoint.Port, connectionNumber: Int) {
		connection = NWConnection(host: host, port: port, using: .tcp)

		self.connectionNumber = connectionNumber

		connection.stateUpdateHandler = { [weak self] state in
			guard let self else { return }

			logger.debug("🔄#\(connectionNumber) \(state)")
			switch state {
			case .ready:
				self.resetSequence()
					.sink { completion in
						switch completion {
						case .finished:
							self.state.value = .ready
							self.receive()
						case let .failure(error):
							self.fail(error)
						}
					} receiveValue: { _ in }
					.store(in: &self.observers)
			case let .failed(error):
				logger.error("❌#\(self.connectionNumber) failed \(error as NSError, privacy: .public)")
				self.fail(error)
			case let .waiting(error):
				logger.warning("❌#\(self.connectionNumber) waiting \(error as NSError, privacy: .public)")

				if case let .posix(code) = error, code == .ECONNREFUSED {
					self.fail(error)
				}
			case .setup:
				break
			case .preparing:
				break
			case .cancelled:
				self.fail(Error.connectionClosed)
			@unknown default:
				break
			}
		}
	}

	func fail(_ error: Swift.Error) {
		switch state.value {
		case .failed:
			break
		default:
			state.value = .failed(error)
			responses.send(completion: .failure(error))
			didCancel?(self)

			connection.cancel()
		}
	}

	func start() -> AnyPublisher<Void, Swift.Error> {
		if state.value == .notReady {
			state.value = .connecting
			connection.start(queue: .main)
		}

		return state
			.tryFilter { state -> Bool in
				switch state {
				case .ready:
					return true
				case let .failed(error):
					throw error
				default:
					return false
				}
			}
			.map { _ in () }
			.first()
			.eraseToAnyPublisher()
	}

	func stop() {
		logger.warning("❌#\(self.connectionNumber) stopping")
		connection.cancel()
	}

	private var sequence: UInt32 = 1

	enum PayloadType {
		case viscaCommand
		case viscaInquery
		case controlCommand
	}

	private func send(_ type: PayloadType, payload: Data) -> AnyPublisher<Void, Swift.Error> {
		var message = Data()
		// payload type
		switch type {
		case .viscaCommand:
			message.append(0x01)
			message.append(0x00)
		case .viscaInquery:
			message.append(0x01)
			message.append(0x10)
		case .controlCommand:
			message.append(0x02)
			message.append(0x00)
		}
		// payload size
		withUnsafeBytes(of: UInt16(payload.count).bigEndian) { pointer in
			message.append(contentsOf: pointer)
		}
		// sequence number
		withUnsafeBytes(of: sequence.bigEndian) { pointer in
			message.append(contentsOf: pointer)
		}

		message.append(payload)

		logger.info("⬆️#\(self.connectionNumber) \(message.hexDescription, privacy: .public)")

		return connection.send(content: message)
			.mapError { $0 as Swift.Error }
			.eraseToAnyPublisher()
	}

	enum ResponsePacket: Equatable {
		case ack
		case completion
		case syntaxError
		case notExecutable

		case inquiryResponse(Data)

		init(_ data: Data) {
			if data == Data([0x41]) {
				self = .ack
			} else if data == Data([0x51]) {
				self = .completion
			} else if data == Data([0x60, 0x02]) {
				self = .syntaxError
			} else if data == Data([0x61, 0x41]) {
				self = .notExecutable
			} else {
				self = .inquiryResponse(data)
			}
		}
	}

	private let responses = PassthroughSubject<ResponsePacket, Swift.Error>()
	private func receive() {
		let connection = self.connection

		var responsePacket = Data()

		func readByte(completion: @escaping (UInt8) -> Void) {
			connection.receive(minimumIncompleteLength: 1, maximumLength: 1) { data, context, isComplete, error in
				if let error {
					logger.error("❌#\(self.connectionNumber) receive failed \(error as NSError, privacy: .public)")
					self.fail(Error.unexpectedBytes)
					return
				}
				guard let byte = data?.first, data?.count == 1 else {
					logger.warning("#\(self.connectionNumber) receive nothing")
					return
				}

				completion(byte)
			}
		}

		func getNext() {
			readByte { byte in
				if byte == 0xFF {
					logger.info("⬇️#\(self.connectionNumber) \(responsePacket.hexDescription, privacy: .public)")

					self.responses.send(ResponsePacket(responsePacket))
					self.receive()
				} else {
					responsePacket.append(byte)
					getNext()
				}
			}
		}

		readByte { byte in
			guard byte == 0x90 else {
				logger.error("❌#\(self.connectionNumber) receive failed")
				self.fail(Error.unexpectedBytes)
				return
			}

			getNext()
		}
	}

	private(set) var isExecuting = false

	private var current: (sequence: UInt32, command: VISCACommand.Group?)?
	private var currentCommandGroup: VISCACommand.Group? {
		current?.command
	}

	func canSend(command: VISCACommand.Group?) -> Bool {
		guard state.value == .ready, !isExecuting else { return false }

		if let command {
			return currentCommandGroup == nil || currentCommandGroup == command
		} else {
			return true
		}
	}

	func send(command: VISCACommand) -> AnyPublisher<Void, Swift.Error> {
		guard !isExecuting else {
			return Fail(error: Error.requestInProgress)
				.eraseToAnyPublisher()
		}
		guard canSend(command: command.group) else {
			return Fail(error: Error.commandInProgress)
				.eraseToAnyPublisher()
		}

		let sequence = self.sequence
		current = (sequence, command.group)

		logger.info("⬆️#\(self.connectionNumber) \(command.name, privacy: .public)")

		return sendVISCACommand(payload: command.payload)
			.handleEvents(receiveCompletion: { completion in
				if case let .failure(error) = completion {
					Tracker.track(error: error, operation: command.name, payload: command.payload)
				}

				guard self.current?.sequence == sequence else { return }
				self.current = nil
				self.didCompleteCommand?(self)
			})
			.disableCancellation()
			.eraseToAnyPublisher()
	}

	private func sendVISCACommand(payload: Data) -> AnyPublisher<Void, Swift.Error> {
		isExecuting = true

		let payload = Data([0x81]) + payload + Data([0xFF])

		return send(.viscaCommand, payload: payload)
			.flatMap {
				self.responses.filter { $0 != .completion }.first()
			}
			.tryMap { response in
				switch response {
				case .ack:
					return
				case .notExecutable:
					throw Error.notExecutable
				case .syntaxError:
					throw Error.syntaxError
				default:
					throw Error.unexpectedBytes
				}
			}
			.timeout(.seconds(1), scheduler: DispatchQueue.main, customError: {
				Error.timeout
			})
			.handleEvents(receiveCompletion: { completion in
				if case let .failure(error) = completion {
					if let error = error as? Error {
						switch error {
						case .notExecutable, .syntaxError:
							break
						default:
							self.fail(error)
							return
						}
					}
				}

				self.sequence += 1
				self.isExecuting = false
				self.didExecute?(self)
			})
			.flatMap {
				self.responses.filter { $0 == .completion }.first()
			}
			.map { data in }
			.disableCancellation()
			.eraseToAnyPublisher()
	}

	func send<Response>(inquiry: VISCAInquiry<Response>) -> AnyPublisher<Response, Swift.Error> {
		guard !isExecuting else {
			return Fail(error: Error.requestInProgress)
				.eraseToAnyPublisher()
		}
		isExecuting = true

		logger.info("⬆️#\(self.connectionNumber) \(inquiry.name, privacy: .public)")

		return sendVISCAInquiry(payload: inquiry.payload)
			.tryMap { payload -> Response in
				guard let response = inquiry.parseResponse(payload) else {
					throw Error.unexpectedBytes
				}
				return response
			}
			.handleEvents(receiveCompletion: { completion in
				if case let .failure(error) = completion {
					if let error = error as? Error {
						switch error {
						case .notExecutable, .syntaxError:
							break
						default:
							self.fail(error)
							return
						}
					}

					Tracker.track(error: error, operation: inquiry.name, payload: inquiry.payload)
				}

				self.sequence += 1
				self.isExecuting = false
				self.didExecute?(self)
			})
			.disableCancellation()
			.eraseToAnyPublisher()
	}

	private func sendVISCAInquiry(payload: Data) -> AnyPublisher<Data, Swift.Error> {
		let payload = Data([0x81]) + payload + Data([0xFF])

		return send(.viscaInquery, payload: payload)
			.flatMap {
				self.responses.filter { $0 != .completion }.first()
			}
			.tryMap { response -> Data in
				switch response {
				case let .inquiryResponse(data):
					return data
				case .notExecutable:
					throw Error.notExecutable
				case .syntaxError:
					throw Error.syntaxError
				default:
					throw Error.unexpectedBytes
				}
			}
			.timeout(.seconds(1), scheduler: DispatchQueue.main, customError: {
				Error.timeout
			})
			.disableCancellation()
			.eraseToAnyPublisher()
	}

	private func resetSequence() -> AnyPublisher<Void, Swift.Error> {
		send(.controlCommand, payload: Data([0x01]))
			.handleEvents(receiveCompletion: { _ in
				self.sequence = 1
			})
			.disableCancellation()
			.map { _ in () }
			.eraseToAnyPublisher()
	}
}

extension VISCAConnection: Hashable {
	static func == (lhs: VISCAConnection, rhs: VISCAConnection) -> Bool {
		lhs === rhs
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(ObjectIdentifier(self))
	}
}
