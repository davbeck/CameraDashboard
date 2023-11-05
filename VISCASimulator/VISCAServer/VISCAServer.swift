import Foundation
import Network

class VISCAServer: ObservableObject {
	let camera = Camera()
	let listener: NWListener
	@Published private(set) var connections: [VISCAServerConnection] = []

	init(port: NWEndpoint.Port) {
		listener = try! NWListener(using: .tcp, on: port)

		listener.stateUpdateHandler = { state in
			print("VISCAServer.stateUpdateHandler", state)
		}
		listener.newConnectionHandler = { [weak self] nwConnection in
			print("VISCAServer.newConnectionHandler", nwConnection)
			guard let self else { return }

			let connection = VISCAServerConnection(camera: self.camera, connection: nwConnection)
			self.connections.append(connection)
			connection.didStopCallback = { [weak self] connection, error in
				self?.connections.removeAll(where: { $0 == connection })
			}
		}
		listener.start(queue: .main)
	}
}
