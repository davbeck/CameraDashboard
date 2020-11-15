//
//  VISCAServer.swift
//  VISCASimulator
//
//  Created by David Beck on 11/15/20.
//

import Foundation
import Network

struct CameraState: Codable {
    var zoom: UInt16 = 0
}

class VISCAServer: ObservableObject {
    let listener: NWListener
    @Published private(set) var connections: Set<VISCAServerConnection> = []

    init(port: NWEndpoint.Port) {
        listener = try! NWListener(using: .tcp, on: port)

        listener.stateUpdateHandler = { state in
            print("VISCAServer.stateUpdateHandler", state)
        }
        listener.newConnectionHandler = { [weak self] nwConnection in
            print("VISCAServer.newConnectionHandler", nwConnection)

            let connection = VISCAServerConnection(connection: nwConnection)
            self?.connections.insert(connection)
            connection.didStopCallback = { [weak self] connection, error in
                print("didStopCallback", error as Any)
                self?.connections.remove(connection)
            }
        }
        listener.start(queue: .main)
    }
    
    @Published var cameraState: CameraState = CameraState()
}
