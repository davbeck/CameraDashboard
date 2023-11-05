import Combine
import CoreData
import Foundation
import Network
import OSLog

private let possiblePorts: [UInt16] = [5678, 1259, 52381]

private let logger = Logger(category: "CameraManager")

class CameraManager: ObservableObject {
	private var observers: Set<AnyCancellable> = []

	static let shared = CameraManager(persistentContainer: .shared)

	let persistentContainer: PersistentContainer

	init(persistentContainer: PersistentContainer = PersistentContainer()) {
		self.persistentContainer = persistentContainer

		loadConfig()
	}

	// MARK: - Config

	private func loadConfig() {
		let context = persistentContainer.viewContext

		NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: context)
			.map { _ in () }.prepend(()) // add initial state
			.map { context.setup.cameras }
			.removeDuplicates()
			.sink { [weak self] cameras in
				guard let self else { return }

				let previous = self.connections.keys
				let added = cameras.set.subtracting(previous)
				let removed = Set(previous).subtracting(cameras)

				for camera in removed {
					self.connections[camera]?.stop()
					self.connections[camera] = nil
				}

				for camera in added {
					self.createConnection(for: camera)
				}

				Tracker.track(numberOfCameras: self.connections.count)
			}
			.store(in: &observers)
	}

	// MARK: - Cameras

	@Published private(set) var connections: [Camera: VISCAClient] = [:]

	private func createConnection(for camera: Camera) {
		let ports = camera.port.map { [$0] } ?? possiblePorts
		self.createConnection(for: camera, ports: ports)
	}

	private func createConnection(
		for camera: Camera,
		ports: [UInt16] = possiblePorts
	) {
		guard
			let portNumber = ports.first,
			let port = NWEndpoint.Port(rawValue: portNumber)
		else { return }

		let client = VISCAClient(
			host: NWEndpoint.Host(camera.address),
			port: port
		)
		self.connections[camera] = client

		client.inquireVersion { result in
			switch result {
			case let .success(version):
				if let oldClient = self.connections[camera] {
					oldClient.stop()
				} else {
					Tracker.trackCameraAdd(version: version, port: portNumber)
				}

				camera.port = portNumber
				try? camera.managedObjectContext?.saveOrRollback()

				Tracker.track(numberOfCameras: self.connections.count)

				camera.objectWillChange
					.throttle(for: 0, scheduler: RunLoop.main, latest: true)
					.first()
					.sink {
						guard camera.port != portNumber else { return }

						self.createConnection(for: camera)
					}
					.store(in: &self.observers)
			case let .failure(error):
				client.stop()
				Tracker.trackCameraAddFailed(error)

				self.createConnection(
					for: camera,
					ports: Array(ports.dropFirst())
				)
			}
		}
	}
}
