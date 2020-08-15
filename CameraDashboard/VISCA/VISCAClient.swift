//
//  VISCAClient.swift
//  CameraDashboard
//
//  Created by David Beck on 8/11/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import Foundation
import Network
import Combine

extension NWEndpoint.Port {
	static var visca: NWEndpoint.Port {
		5678
	}
}

extension NWConnection {
	func send(content: Data?, contentContext: NWConnection.ContentContext = .defaultMessage, isComplete: Bool = true) -> Future<Void, NWError> {
		return Future { promise in
			self.send(content: content, contentContext: contentContext, isComplete: isComplete, completion: .contentProcessed { error in
				if let error = error {
					promise(.failure(error))
				} else {
					promise(.success(()))
				}
			})
		}
	}
	
	func receive(minimumIncompleteLength: Int, maximumLength: Int) -> Future<Data, NWError> {
		Future { promise in
			self.receive(minimumIncompleteLength: minimumIncompleteLength, maximumLength: maximumLength) { data, context, isComplete, error in
				if let error = error {
					promise(.failure(error))
				} else if let data = data {
					promise(.success(data))
				}
			}
		}
	}
}

class VISCAClient: ObservableObject {
	let connection: NWConnection
	
	enum Error: Swift.Error, LocalizedError {
		case invalidInitialResponseByte
		case unexpectedBytes
		case missingAck
		case missingCompletion
		case notReady
		case timeout
		
		var errorDescription: String? {
			switch self {
			case .invalidInitialResponseByte:
				return "Received an invalid response from the camera."
			case .unexpectedBytes:
				return "Received unexpected data from the camera."
			case .missingAck:
				return "The camera did not respond."
			case .missingCompletion:
				return "The camera did not respond after updating."
			case .notReady:
				return "The camera is not connected."
			case .timeout:
				return "The operation timed out."
			}
		}
	}
	
	enum State {
		case inactive
		case connecting
		case error(Swift.Error)
		case ready
	}
	
	@Published private(set) var state: State = .inactive
	
	private var observers: Set<AnyCancellable> = []
	
	init(host: NWEndpoint.Host, port: NWEndpoint.Port) {
		self.connection = NWConnection(host: host, port: port, using: .tcp)
		
		connection.stateUpdateHandler = { [weak self] state in
			guard let self = self else { return }
			
			print("VISCAClient.stateUpdateHandler", state)
			switch state {
			case .ready:
				self.state = .ready
				
				self.resetSequence()
				self.sendCallback(.success(()))
			case .failed(let error):
				switch self.state {
				case .ready:
					self.restart()
				case .connecting:
					Timer.scheduledTimer(withTimeInterval: 30, repeats: false) { _ in
						self.restart()
					}
				default:
					break
				}
				
				self.state = .error(error)
				
				self.sendCallback(.failure(error))
			case .waiting(let error):
				self.state = .error(error)
				
				self.sendCallback(.failure(error))
			case .setup:
				break
			case .preparing:
				break
			case .cancelled:
				if case .inactive = self.state {
					break
				}
				
				self.start()
			@unknown default:
				break
			}
		}
	}
	
	private var connectionCallback: ((Result<Void, NWError>) -> Void)?
	
	private func sendCallback(_ result: Result<Void, NWError>) {
		if let connectionCallback = self.connectionCallback {
			connectionCallback(result)
			self.connectionCallback = nil
		}
	}
	
	func start(_ completion: ((Result<Void, NWError>) -> Void)? = nil) {
		self.connectionCallback = completion
		state = .connecting
		
		connection.start(queue: .main)
	}
	
	func restart() {
		if case .inactive = state {
			return
		}
		
		connection.cancel()
	}
	
	func stop() {
		state = .inactive
		
		connection.cancel()
	}
	
	// MARK: - Payloads
	
	private var sequence: UInt32 = 1
	
	enum PayloadType {
		case viscaCommand
		case viscaInquery
		case controlCommand
	}
	
	private func send(_ type: PayloadType, payload: Data) -> AnyPublisher<Void, Swift.Error> {
		guard case .ready = state else {
			return Fail(error: Error.notReady).eraseToAnyPublisher()
		}
		
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
		
		print("⬆️", message.map { $0.hexDescription }.joined(separator: " "))
		
		return connection.send(content: message)
			.mapError { $0 as Swift.Error }
			.map { _ -> Void in
				self.sequence += 1
			}
			.eraseToAnyPublisher()
	}
	
	private func receive() -> Future<Data, Swift.Error> {
		let connection = self.connection
		
		return Future<Data, Swift.Error> { promise in
			var responsePacket = Data()
			
			func readByte(completion: @escaping (UInt8) -> Void) {
				connection.receive(minimumIncompleteLength: 1, maximumLength: 1) { data, context, isComplete, error in
					print("receiveMessage", data?.map { $0.hexDescription }.joined(separator: " "), context, isComplete, error)
					
					if let error = error {
						promise(.failure(error))
						return
					}
					
					guard let data = data, data.count == 1 else {
						self.connection.cancel()
						promise(.failure(Error.unexpectedBytes))
						return
					}
					
					completion(data[0])
				}
			}
			
			func getNext() {
				readByte { byte in
					if byte == 0xFF {
						promise(.success(responsePacket))
					} else {
						responsePacket.append(byte)
						getNext()
					}
				}
			}
			
			readByte { byte in
				guard byte == 0x90 else {
					self.connection.cancel()
					promise(.failure(Error.invalidInitialResponseByte))
					return
				}
				
				getNext()
			}
		}
	}
	
	private func sendVISCACommand(payload: Data, attempt: Int = 0) -> AnyPublisher<Void, Swift.Error> {
		return self.send(.viscaCommand, payload: payload)
			.flatMap {
				self.receive()
			}
			.tryMap { (data) -> Void in
				guard data == Data([0x41]) else { throw Error.missingAck }
			}
			.flatMap {
				self.receive()
			}
			.tryMap { (data) -> Void in
				guard data == Data([0x51]) else { throw Error.missingCompletion }
			}
			.timeout(.seconds(10), scheduler: RunLoop.main, customError: {
				Error.timeout
			})
			.tryCatch({ (error) -> AnyPublisher<Void, Swift.Error> in
				if error as? Error == Error.timeout && attempt < 3 {
					return self.sendVISCACommand(payload: payload, attempt: attempt + 1)
				} else {
					self.restart()
					throw error
				}
			})
			.eraseToAnyPublisher()
	}
	
	private func sendVISCAInquiry(payload: Data) -> AnyPublisher<Data, Swift.Error> {
		self.send(.viscaInquery, payload: payload)
			.flatMap {
				self.receive()
			}
			.timeout(.seconds(10), scheduler: RunLoop.main, customError: {
				Error.timeout
			})
			.eraseToAnyPublisher()
	}
	
	func resetSequence() {
		self.send(.controlCommand, payload: Data([0x01]))
			.sink { completion in
				self.sequence = 1
			} receiveValue: {}
			.store(in: &observers)
	}
	
	// MARK: - Presets
	
	@Published var currentPreset: VISCAPreset?
	@Published var nextPreset: VISCAPreset?
	
	@discardableResult
	func recall(preset: VISCAPreset) -> AnyPublisher<Void, Swift.Error> {
		self.nextPreset = preset
		
		let publisher = self.sendVISCACommand(payload: Data([0x81, 0x01, 0x04, 0x3F, 0x02, preset.rawValue, 0xFF]))
			.share()
		
		publisher
			.sink { completion in
				switch completion {
				case .finished:
					self.currentPreset = preset
				case .failure:
					self.nextPreset = nil
				}
			} receiveValue: {}
			.store(in: &observers)

		return publisher.eraseToAnyPublisher()
	}
}

extension VISCAClient: Hashable {
	static func == (lhs: VISCAClient, rhs: VISCAClient) -> Bool {
		return lhs === rhs
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(ObjectIdentifier(self))
	}
}
