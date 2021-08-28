import Foundation
import Combine
import MIDIKit
import CoreMIDI

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

extension ConfigKey {
	static func actionIDs() -> ConfigKey<[UUID]> {
		.init(rawValue: "actionIDs", defaultValue: [])
	}

	static func action(id: UUID) -> ConfigKey<Action> {
		.init(rawValue: "action:\(id)", defaultValue: Action())
	}
}

class ActionsManager: ObservableObject {
	private var observers: Set<AnyCancellable> = []
	
	let configManager: ConfigManager
	let cameraManager: CameraManager
	let switcherManager: SwitcherManager
	
	let client: MIDIClient
	let inputPort: MIDIInputPort
	
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
	}
	
	private var endpoint: MIDIVirtualDestination?
	func connect() {
		do {
			let id = (UserDefaults.standard.object(forKey: "ActionMIDIUniqueID") as? NSNumber)?.int32Value
				?? MIDIUniqueID.random(in: MIDIUniqueID.min...MIDIUniqueID.max)
	  
			let endpoint = try client.createDestination(name: "CameraDashboard")
			try endpoint.setUniqueID(id)
			endpoint.packetRecieved
				.receive(on: RunLoop.main)
				.sink { [weak self] packet in
					self?.handle(packet)
				}
				.store(in: &observers)
			self.endpoint = endpoint
			try inputPort.connect(source: endpoint)
	  
			UserDefaults.standard.set(id, forKey: "ActionMIDIUniqueID")
		} catch {
			print("failed to create endpoint")
		}
	}
	
	private func action(for packet: MIDIPacket) -> Action? {
		for id in configManager[.actionIDs()] {
			let action = configManager[.action(id: id)]
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
