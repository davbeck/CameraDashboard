//
//  VISCAClient.swift
//  CameraDashboard
//
//  Created by David Beck on 8/11/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import Foundation
import Network

extension NWEndpoint.Port {
	static var visca: NWEndpoint.Port {
		5678
	}
}

class VISCAClient: ObservableObject {
	let connection: NWConnection
	
	enum State {
		case inactive
		case connecting
		case error(Swift.Error)
		case ready
	}
	
	@Published private(set) var state: State = .inactive
	
	init(host: NWEndpoint.Host, port: NWEndpoint.Port) {
		self.connection = NWConnection(host: host, port: port, using: .tcp)
		
		connection.stateUpdateHandler = { [weak self] state in
			guard let self = self else { return }
			
			print("VISCAClient.stateUpdateHandler", state)
			switch state {
			case .ready:
				self.state = .ready
				
				self.sendCallback(.success(()))
			case .failed(let error):
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
				break
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
	
	func stop() {
		state = .inactive
		
		connection.cancel()
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
