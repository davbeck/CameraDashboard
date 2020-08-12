//
//  CameraManager.swift
//  CameraDashboard
//
//  Created by David Beck on 8/11/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import Foundation
import Network
import Combine

struct Camera: Codable, Hashable, Identifiable {
	private(set) var id = UUID()
	var name: String?
	var address: String
	var port: UInt16?
}

struct CameraConfig: Codable, Hashable {
	var cameras: [Camera]
}

struct CameraConnection: Hashable, Identifiable {
	var camera: Camera
	let client: VISCAClient
	
	var id: UUID {
		camera.id
	}
}

class CameraManager: ObservableObject {
	static let shared: CameraManager = {
		let url = try? FileManager.default
			.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
			.appendingPathComponent("CameraConfig.json", isDirectory: false)
		
		return CameraManager(configURL: url)
	}()
	
	init(configURL: URL? = nil) {
		self.configURL = configURL
		
		loadConfig()
		
		for connection in connections {
			connection.client.start()
		}
	}
	
	// MARK: - Config
	
	let configURL: URL?
	
	func loadConfig() {
		do {
			guard let configURL = configURL else { return }
			
			let data = try Data(contentsOf: configURL)
			let config = try JSONDecoder().decode(CameraConfig.self, from: data)
			
			self.connections = config.cameras.map { camera in
				CameraConnection(camera: camera, client: VISCAClient(
					host: NWEndpoint.Host(camera.address),
					port: camera.port.map(NWEndpoint.Port.init) ?? .visca
				))
			}
		} catch {
			print("failed to load config", error)
		}
	}
	
	func saveConfig() {
		do {
			guard let configURL = configURL else { return }
			
			let data = try JSONEncoder().encode(CameraConfig(cameras: connections.map { $0.camera }))
			try data.write(to: configURL, options: .atomic)
		} catch {
			print("failed to save confing", error)
		}
	}
	
	// MARK: - Cameras
	
	private(set) var connections: [CameraConnection] = []
	
	func add(camera: Camera, completion: @escaping (Result<CameraConnection, Swift.Error>) -> Void) {
		let connection = CameraConnection(camera: camera, client: VISCAClient(camera))
		
		connection.client.start { result in
			switch result {
			case .success:
				self.connections.append(connection)
				self.saveConfig()
				
				completion(.success(connection))
			case .failure(let error):
				connection.client.stop()
				
				completion(.failure(error))
			}
		}
	}
}

extension VISCAClient {
	convenience init(_ camera: Camera) {
		self.init(
			host: NWEndpoint.Host(camera.address),
			port: camera.port.map(NWEndpoint.Port.init) ?? .visca
		)
	}
}
