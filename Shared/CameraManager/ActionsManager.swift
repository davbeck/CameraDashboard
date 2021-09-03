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

struct Action: Codable, Equatable {
	var name: String = ""
	var status: MIDIStatus = .noteOn
	var channel: UInt8 = 0
	var note: UInt8 = 0
	
	var cameraID: UUID?
	var preset = VISCAPreset.allCases[0]
	var switchInput: Bool = true
	
	func matches(_ packet: MIDIPacket) -> Bool {
		return status == packet.status && channel == packet.channel && note == packet.note
	}
}

struct ActionIDsKey: ConfigKey {
	static let defaultValue: [UUID] = []

	var rawValue: String {
		"actionIDs"
	}
}

struct ActionKey: ConfigKey {
	static let defaultValue = Action()

	var rawValue: String {
		"action:\(id)"
	}
	
	var id: UUID
}

class ActionsManager: ObservableObject {
	private var observers: Set<AnyCancellable> = []
	
	let configManager: ConfigManager
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
		configManager: .shared,
		cameraManager: .shared,
		switcherManager: .shared
	)
	
	init(
		configManager: ConfigManager,
		cameraManager: CameraManager,
		switcherManager: SwitcherManager
	) {
		self.configManager = configManager
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
		for id in configManager[ActionIDsKey()] {
			let action = configManager[ActionKey(id: id)]
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
		guard let connection = cameraManager.connections.first(where: { $0.id == action.cameraID }) else { return }
		connection.client.recall(preset: action.preset)
		
		connection.client.$preset.filter { $0.remote == action.preset }.first()
			.sink { [switcherManager] _ in
				if action.switchInput, let cameraID = action.cameraID {
					switcherManager.selectCamera(id: cameraID)
				}
			}
			.store(in: &observers)
	}
}
