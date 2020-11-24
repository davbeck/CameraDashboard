import Foundation
import Combine
import Network

private protocol AnyVISCAPoolRequest {
	func run(_ connection: VISCAConnection, completion: @escaping (Swift.Error?) -> Void)
}

class VISCAPool {
	enum Error: Swift.Error, LocalizedError {
		case timeout
		
		var errorDescription: String? {
			switch self {
			case .timeout:
				return "The operation timed out."
			}
		}
	}
	
	private var observers: Set<AnyCancellable> = []
	
	private var connections: Set<VISCAConnection> = []
	private var connectionNumber: Int = 0
	
	let maxConnections: Int
	let host: NWEndpoint.Host
	let port: NWEndpoint.Port
	
	init(host: NWEndpoint.Host, port: NWEndpoint.Port, maxConnections: Int = 3) {
		self.host = host
		self.port = port
		self.maxConnections = maxConnections
	}
	
	func stop() {
		DispatchQueue.visca.async {
			for connection in self.connections {
				connection.stop()
			}
			self.connections = []
		}
	}
	
	private var requestQueue: [(command: VISCACommand.Group?, subject: PassthroughSubject<VISCAConnection, Never>)] = []
	
	private func createConnection() -> VISCAConnection {
		connectionNumber += 1
		let connection = VISCAConnection(host: host, port: port, connectionNumber: connectionNumber)
		connections.insert(connection)
		connection.didCancel = { [weak self] connection in
			connection.didCancel = nil
			self?.connections.remove(connection)
		}
		connection.didExecute = { [weak self] connection in
			self?.dequeue()
		}
		connection.didCompleteCommand = { [weak self] connection in
			self?.dequeue()
		}
		return connection
	}
	
	private func getConnection(command: VISCACommand.Group? = nil) -> VISCAConnection? {
		if let connection = connections.first(where: { $0.canSend(command: command) }) {
//			print("returning available connection")
			return connection
		} else if connections.count < maxConnections, !connections.contains(where: { !$0.isReady }) {
//			print("create connection")
			return createConnection()
		} else {
//			print("no connection available")
			return nil
		}
	}
	
	private func dequeue() {
		guard let request = requestQueue.first else { return }
		guard let connection = getConnection(command: request.command) else { return }
		requestQueue.removeFirst()
		
		request.subject.send(connection)
		request.subject.send(completion: .finished)
	}
	
	private func aquire(command: VISCACommand.Group? = nil) -> AnyPublisher<VISCAConnection, Swift.Error> {
		if requestQueue.isEmpty, let connection = getConnection(command: command) {
			return connection.start()
				.map { connection }
				.eraseToAnyPublisher()
		} else {
			let subject = PassthroughSubject<VISCAConnection, Never>()
			requestQueue.append((command, subject))
			return subject
				.flatMap { connection in
					connection.start()
						.map { connection }
				}
				.eraseToAnyPublisher()
		}
	}
	
	func send(command: VISCACommand) -> AnyPublisher<Void, Swift.Error> {
		dispatchPrecondition(condition: .onQueue(.visca))
		return aquire(command: command.group)
			.flatMap { $0.send(command: command) }
			.timeout(.seconds(10), scheduler: DispatchQueue.visca, customError: {
				Error.timeout
			})
			.eraseToAnyPublisher()
	}
	
	func send<Response>(inquiry: VISCAInquiry<Response>) -> AnyPublisher<Response, Swift.Error> {
		dispatchPrecondition(condition: .onQueue(.visca))
		return aquire()
			.flatMap { $0.send(inquiry: inquiry) }
			.timeout(.seconds(10), scheduler: DispatchQueue.visca, customError: {
				Error.timeout
			})
			.eraseToAnyPublisher()
	}
}
