import Foundation
import Combine
import MIDIKit
import CoreMIDI
import Defaults

private extension Defaults.Keys {
	static let inputID = Key<MIDIUniqueID?>("ActionsManager.inputID", default: nil)
	static let virtualID = Key<MIDIUniqueID?>("ActionsManager.virtualID", default: nil)
}

extension MIDIStatus: Codable {}

extension Action {
	func matches(_ packet: MIDIPacket) -> Bool {
		return status == packet.status && channel == packet.channel && note == packet.note
	}
}

class ActionsManager: ObservableObject {
	private var observers: Set<AnyCancellable> = []
	
	let persistentContainer: PersistentContainer
	let cameraManager: CameraManager
	let switcherManager: SwitcherManager
	
	let client: MIDIClient
	let inputPort: MIDIInputPort
	
	@Published var sources = MIDIEndpoint.allSources
	@Published var input: MIDIEndpoint? {
		didSet {
			if let input = oldValue {
				try? inputPort.disconnect(source: input)
			}
			
			if let input = input {
				do {
					try inputPort.connect(source: input)
					inputError = nil
				} catch {
					inputError = error
				}
			}
			
			Defaults[.inputID] = input?.uniqueID
		}
	}

	@Published var inputError: Swift.Error?
	
	static let shared = ActionsManager(
		persistentContainer: .shared,
		cameraManager: .shared,
		switcherManager: .shared
	)
	
	init(
		persistentContainer: PersistentContainer,
		cameraManager: CameraManager,
		switcherManager: SwitcherManager
	) {
		self.persistentContainer = persistentContainer
		self.cameraManager = cameraManager
		self.switcherManager = switcherManager
		
		self.client = try! MIDIClient(name: "CameraDashboard-ActionsManager")
		self.inputPort = try! MIDIInputPort(client: client, name: "ActionsManager Input Port")
		
		if let id = Defaults[.inputID], let endpoint = try? MIDIEndpoint(uniqueID: id) {
			self.input = endpoint
		}
		
		self.client.setupChanged
			.sink { [weak self] _ in
			guard let self = self else { return }
				
			let sources = MIDIEndpoint.allSources
			if self.sources != sources {
				self.sources = sources
			}
		}
		.store(in: &observers)
		
		inputPort.packetRecieved
			.receive(on: RunLoop.main)
			.sink { [weak self] packet in
			self?.handle(packet)
		}
		.store(in: &observers)
	}
	
	private var endpoint: MIDIVirtualDestination?
	func connect() {
		do {
			let id = Defaults[.virtualID] ?? MIDIUniqueID.random(in: MIDIUniqueID.min...MIDIUniqueID.max)
	  
			let endpoint = try client.createDestination(name: "CameraDashboard")
			try endpoint.setUniqueID(id)
			endpoint.packetRecieved
				.receive(on: RunLoop.main)
				.sink { [weak self] packet in
					guard self?.input == nil else { return }
					self?.handle(packet)
				}
				.store(in: &observers)
			self.endpoint = endpoint
	  
			Defaults[.virtualID] = id
		} catch {
			print("failed to create endpoint")
		}
	}
	
	private func action(for packet: MIDIPacket) -> Action? {
		for action in persistentContainer.viewContext.setup.actions {
			if action.matches(packet) {
				return action
			}
		}
		
		return nil
	}
	
	private func handle(_ packet: MIDIPacket) {
		guard let action = action(for: packet) else { return }
		perform(action)
	}
	
	func perform(_ action: Action) {
		guard
			let presetConfig = action.preset,
			let client = cameraManager.connections[presetConfig.camera]
		else { return }
		
		client.recall(preset: presetConfig.preset)
		
		client.$preset.filter { $0.remote == presetConfig.preset }.first()
			.sink { [switcherManager] _ in
				if action.switchInput {
					switcherManager.select(presetConfig.camera)
				}
			}
			.store(in: &observers)
	}
}
