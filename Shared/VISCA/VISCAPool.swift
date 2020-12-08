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
		for connection in connections {
			connection.stop()
		}
		connections = []
	}
	
	enum Target: Equatable {
		case commmand(VISCACommand.Group)
		case inquiry(Data)
		
		func matches(_ other: Target) -> Bool {
			switch (self, other) {
			case let (.commmand(group), .commmand(otherGroup)):
				return !group.intersection(otherGroup).isEmpty
			case let (.inquiry(payload), .inquiry(otherPayload)):
				return payload == otherPayload
			default:
				return false
			}
		}
		
		var commandGroup: VISCACommand.Group? {
			switch self {
			case let .commmand(group):
				return group
			case .inquiry:
				return nil
			}
		}
	}
	
	struct QueueItem {
		let target: Target
		let subject = PassthroughSubject<VISCAConnection, Swift.Error>()
	}
	
	private var requestQueue: [QueueItem] = []
	
	private func createConnection() -> VISCAConnection {
		connectionNumber += 1
		let connection = VISCAConnection(host: host, port: port, connectionNumber: connectionNumber)
		connections.insert(connection)
		connection.didCancel = { [weak self] connection in
			connection.didCancel = nil
			self?.connections.remove(connection)
			
			self?.dequeue()
		}
		connection.didExecute = { [weak self] connection in
			self?.dequeue()
		}
		connection.didCompleteCommand = { [weak self] connection in
			self?.dequeue()
		}
		return connection
	}
	
	private func getConnection(target: Target) -> VISCAConnection? {
		if let connection = connections.first(where: { $0.canSend(command: target.commandGroup) }) {
			return connection
		} else if connections.count < maxConnections, !connections.contains(where: { $0.state.value == .connecting }) {
			return createConnection()
		} else {
			return nil
		}
	}
	
	private func dequeue() {
		guard let request = requestQueue.first else { return }
		guard let connection = getConnection(target: request.target) else { return }
		requestQueue.removeFirst()
		
		request.subject.send(connection)
		request.subject.send(completion: .finished)
	}
	
	private func aquire(target: Target) -> AnyPublisher<VISCAConnection, Swift.Error> {
		if requestQueue.isEmpty, let connection = getConnection(target: target) {
			return connection.start()
				.map { connection }
				.eraseToAnyPublisher()
		} else {
			let item = QueueItem(target: target)
			for request in requestQueue.filter({ $0.target.matches(item.target) }) {
				request.subject.send(completion: .failure(CommandOverriddenError()))
			}
			requestQueue.removeAll(where: { $0.target.matches(item.target) })
			
			requestQueue.append(item)
			return item.subject
				.flatMap { connection in
					connection.start()
						.map { connection }
				}
				.eraseToAnyPublisher()
		}
	}
	
	func send(command: VISCACommand) -> AnyPublisher<Void, Swift.Error> {
		return aquire(target: .commmand(command.group))
			.flatMap {
				$0.send(command: command)
			}
			.eraseToAnyPublisher()
	}
	
	func send<Response>(inquiry: VISCAInquiry<Response>) -> AnyPublisher<Response, Swift.Error> {
		return aquire(target: .inquiry(inquiry.payload))
			.flatMap {
				$0.send(inquiry: inquiry)
			}
			.eraseToAnyPublisher()
	}
}
