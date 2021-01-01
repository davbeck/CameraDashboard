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
						port: camera.port.map(NWEndpoint.Port.init) ?? .visca
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
	
	func save(camera: Camera, completion: @escaping (Result<CameraConnection, Swift.Error>) -> Void) {
		if let index = connections.firstIndex(where: { $0.camera.id == camera.id }),
			connections[index].camera.address == camera.address,
			connections[index].camera.port == camera.port {
			connections[index].camera = camera
			saveConfig()
			return completion(.success(connections[index]))
		}
		
		let connection = CameraConnection(
			camera: camera,
			client: VISCAClient(camera),
			cameraNumber: connections.count
		)
		
		connection.client.inquireVersion { result in
			switch result {
			case let .success(version):
				if let index = self.connections.firstIndex(where: { $0.camera.id == camera.id }) {
					self.connections[index].client.stop()
					self.connections[index] = connection
				} else {
					self.connections.append(connection)
					self.didAddCamera.send(camera)
					
					Tracker.track(numberOfCameras: self.connections.count)
				}
				
				self.saveConfig()
				
				completion(.success(connection))
				
				Tracker.trackCameraAdd(version: version, port: camera.port ?? 5678)
			case let .failure(error):
				connection.client.stop()
				completion(.failure(error))
				
				Tracker.trackCameraAddFailed(error)
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
			port: camera.port.map(NWEndpoint.Port.init) ?? .visca
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
