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

struct CameraConnection: Hashable, Identifiable {
	var camera: Camera
	let client: VISCAClient
	
	var id: UUID {
		camera.id
	}
}

class CameraManager: ObservableObject {
	enum Error: Swift.Error {
		case cameraDoesNotExist
	}
	
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
	
	struct CameraConfig: Codable, Hashable {
		var cameras: [Camera]
		var presetConfigs: [PresetConfig] = []
		
		init(cameras: [Camera], presetConfigs: [PresetConfig] = []) {
			self.cameras = cameras
			self.presetConfigs = presetConfigs
		}
		
		init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			
			self.cameras = try container.decodeIfPresent([Camera].self, forKey: .cameras) ?? []
			self.presetConfigs = try container.decodeIfPresent([PresetConfig].self, forKey: .presetConfigs) ?? []
		}
	}
	
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
			self.presetConfigs = config.presetConfigs
		} catch {
			print("failed to load config", error)
		}
	}
	
	func saveConfig() {
		do {
			guard let configURL = configURL else { return }
			
			let config = CameraConfig(
				cameras: connections.map { $0.camera },
				presetConfigs: presetConfigs
			)
			
			let data = try JSONEncoder().encode(config)
			try data.write(to: configURL, options: .atomic)
		} catch {
			print("failed to save confing", error)
		}
	}
	
	// MARK: - Cameras
	
	private(set) var connections: [CameraConnection] = []
	
	func save(camera: Camera, completion: @escaping (Result<CameraConnection, Swift.Error>) -> Void) {
		if let index = self.connections.firstIndex(where: { $0.camera.id == camera.id }),
			connections[index].camera.address == camera.address,
			connections[index].camera.port == camera.port
		{
			connections[index].camera = camera
			return completion(.success(connections[index]))
		}
		
		let connection = CameraConnection(camera: camera, client: VISCAClient(camera))
		
		connection.client.start { result in
			switch result {
			case .success:
				if let index = self.connections.firstIndex(where: { $0.camera.id == camera.id }) {
					self.connections[index].client.stop()
					self.connections[index] = connection
				} else {
					self.connections.append(connection)
				}
				
				self.saveConfig()
				
				completion(.success(connection))
			case .failure(let error):
				connection.client.stop()
				
				completion(.failure(error))
			}
		}
	}
	
	// MARK: - Preset Config
	
	@Published private var presetConfigs: [PresetConfig] = []
	
	func presets(for camera: Camera) -> [PresetConfig] {
		VISCAPreset.allCases.map { preset in
			presetConfigs.first(where: {
				$0.cameraID == camera.id && $0.preset == preset
			}) ?? PresetConfig(cameraID: camera.id, preset: preset)
		}
	}
	
	func save(_ presetConfig: PresetConfig) {
		if let index = presetConfigs.firstIndex(where: { $0.cameraID == presetConfig.cameraID && $0.preset == presetConfig.preset }) {
			presetConfigs[index] = presetConfig
		} else {
			presetConfigs.append(presetConfig)
		}
		
		self.saveConfig()
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
