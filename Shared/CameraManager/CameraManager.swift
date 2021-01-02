import Foundation
import Network
import Combine
import OSLog

private let logger = Logger(category: "CameraManager")

struct CameraConnection: Hashable, Identifiable {
	var camera: Camera
	let client: VISCAClient
	var cameraNumber: Int
	
	var id: UUID {
		camera.id
	}
	
	var displayName: String {
		camera.name.isEmpty ? "Camera \(cameraNumber + 1)" : camera.name
	}
}

class CameraManager: ObservableObject {
	static let shared: CameraManager = {
		let url = try? FileManager.default
			.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
			.appendingPathComponent(Bundle(for: CameraManager.self).bundleIdentifier ?? "CameraDashboard")
			.appendingPathComponent("CameraConfig.json", isDirectory: false)
		
		return CameraManager(configURL: url)
	}()
	
	init(configURL: URL? = nil) {
		self.configURL = configURL
		
		loadConfig()
	}
	
	// MARK: - Config
	
	let configURL: URL?
	let queue = DispatchQueue(label: "CameraManager")
	
	struct CameraConfig: Codable, Hashable {
		var cameras: [Camera]
		var presetConfigs: [PresetKey: PresetConfig] = [:]
		
		init(cameras: [Camera], presetConfigs: [PresetKey: PresetConfig] = [:]) {
			self.cameras = cameras
			self.presetConfigs = presetConfigs
		}
		
		init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			
			cameras = try container.decodeIfPresent([Camera].self, forKey: .cameras) ?? []
			presetConfigs = (try? container.decodeIfPresent([PresetKey: PresetConfig].self, forKey: .presetConfigs)) ?? [:]
		}
	}
	
	func loadConfig() {
		do {
			guard let configURL = configURL else { return }
			
			let data = try Data(contentsOf: configURL)
			let config = try JSONDecoder().decode(CameraConfig.self, from: data)
			
			connections = config.cameras.enumerated().map { (number, camera) -> CameraConnection in
				CameraConnection(
					camera: camera,
					client: VISCAClient(
						host: NWEndpoint.Host(camera.address),
						port: NWEndpoint.Port(rawValue: camera.port)!
					),
					cameraNumber: number
				)
			}
			presetConfigs = config.presetConfigs
			
			Tracker.track(numberOfCameras: connections.count)
		} catch {
			logger.error("failed to load config: \(error as NSError, privacy: .public)")
		}
	}
	
	func saveConfig() {
		queue.async {
			do {
				guard let configURL = self.configURL else { return }
				try FileManager.default.createDirectory(
					at: configURL.deletingLastPathComponent(),
					withIntermediateDirectories: true,
					attributes: nil
				)
				
				let config = CameraConfig(
					cameras: self.connections.map { $0.camera },
					presetConfigs: self.presetConfigs
				)
				
				let data = try JSONEncoder().encode(config)
				try data.write(to: configURL, options: .atomic)
			} catch {
				logger.error("failed to save config: \(error as NSError, privacy: .public)")
			}
		}
	}
	
	// MARK: - Cameras
	
	@Published private(set) var connections: [CameraConnection] = []
	
	let didAddCamera = PassthroughSubject<Camera, Never>()
	
	func save(camera: Camera, port: UInt16?, completion: @escaping (Result<CameraConnection, Swift.Error>) -> Void) {
		if let index = connections.firstIndex(where: { $0.camera.id == camera.id }),
			connections[index].camera.address == camera.address,
			connections[index].camera.port == port {
			connections[index].camera = camera
			saveConfig()
			return completion(.success(connections[index]))
		}
		
		if let port = port {
			createConnection(id: camera.id, name: camera.name, address: camera.address, ports: [port], completion: completion)
		} else {
			createConnection(id: camera.id, name: camera.name, address: camera.address, completion: completion)
		}
	}
	
	func createCamera(name: String, address: String, port: UInt16?, completion: @escaping (Result<CameraConnection, Swift.Error>) -> Void) {
		if let port = port {
			createConnection(name: name, address: address, ports: [port], completion: completion)
		} else {
			createConnection(name: name, address: address, completion: completion)
		}
	}
	
	private func createConnection(id: UUID = UUID(), name: String, address: String, ports: [UInt16] = [5678, 1259, 52381], completion: @escaping (Result<CameraConnection, Swift.Error>) -> Void) {
		let camera = Camera(id: id, name: name, address: address, port: ports[0])
		let client = VISCAClient(camera)
		
		client.inquireVersion { result in
			switch result {
			case let .success(version):
				var connection = CameraConnection(
					camera: camera,
					client: client,
					cameraNumber: self.connections.count
				)
				
				if let index = self.connections.firstIndex(where: { $0.camera.id == camera.id }) {
					connection.cameraNumber = index
					self.connections[index].client.stop()
					self.connections[index] = connection
				} else {
					self.connections.append(connection)
					self.didAddCamera.send(camera)
					
					Tracker.track(numberOfCameras: self.connections.count)
				}
				
				self.saveConfig()
				
				Tracker.trackCameraAdd(version: version, port: camera.port)
				
				completion(.success(connection))
			case let .failure(error):
				client.stop()
				Tracker.trackCameraAddFailed(error)
				
				guard ports.count > 1 else {
					completion(.failure(error))
					return
				}
				self.createConnection(
					name: name,
					address: address,
					ports: Array(ports.dropFirst()),
					completion: completion
				)
			}
		}
	}
	
	let didRemoveCamera = PassthroughSubject<Camera, Never>()
	
	func remove(camera: Camera) {
		for connection in connections.filter({ $0.camera.id == camera.id }) {
			connection.client.stop()
		}
		
		connections.removeAll(where: { $0.camera.id == camera.id })
		saveConfig()
		
		didRemoveCamera.send(camera)
		
		Tracker.track(numberOfCameras: self.connections.count)
	}
	
	// MARK: - Preset Config
	
	@Published private var presetConfigs: [PresetKey: PresetConfig] = [:]
	
	subscript(camera: Camera, preset: VISCAPreset) -> PresetConfig {
		get {
			presetConfigs[PresetKey(cameraID: camera.id, preset: preset)] ??
				PresetConfig()
		}
		set(newValue) {
			presetConfigs[PresetKey(cameraID: camera.id, preset: preset)] = newValue
			
			saveConfig()
		}
	}
}

extension VISCAClient {
	convenience init(_ camera: Camera) {
		self.init(
			host: NWEndpoint.Host(camera.address),
			port: NWEndpoint.Port(rawValue: camera.port)!
		)
	}
}

#if DEBUG
	extension CameraConnection {
		init() {
			self.init(
				camera: Camera(address: ""),
				client: VISCAClient(host: "0.0.0.0", port: 1234),
				cameraNumber: 2
			)
		}
	}
#endif
