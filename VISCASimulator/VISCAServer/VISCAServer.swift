//
//  VISCAServer.swift
//  VISCASimulator
//
//  Created by David Beck on 11/15/20.
//

import Foundation
import Network

class VISCAServer: ObservableObject {
    let camera = Camera()
    let listener: NWListener
    @Published private(set) var connections: Set<VISCAServerConnection> = []

    init(port: NWEndpoint.Port) {
        listener = try! NWListener(using: .tcp, on: port)

        listener.stateUpdateHandler = { state in
            print("VISCAServer.stateUpdateHandler", state)
        }
        listener.newConnectionHandler = { [weak self] nwConnection in
            print("VISCAServer.newConnectionHandler", nwConnection)
            guard let self = self else { return }

            let connection = VISCAServerConnection(camera: self.camera, connection: nwConnection)
            self.connections.insert(connection)
            connection.didStopCallback = { [weak self] connection, error in
                print("didStopCallback", error as Any)
                self?.connections.remove(connection)
            }
        }
        listener.start(queue: .main)
    }
}
