import Foundation
import Combine
import MIDIKit

extension MIDIStatus: Codable {}

struct Action: Codable {
	var name: String = ""
	var status: MIDIStatus = .noteOn
	var channel: UInt8 = 0
	var note: UInt8 = 0
	
	var cameraID: UUID?
	var preset = VISCAPreset.allCases[0]
	var switchInput: Bool = true
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
	
	let client: MIDIClient
	
	static let shared = ActionsManager(configManager: .shared)
	
	init(configManager: ConfigManager) {
		self.configManager = configManager
		
		self.client = try! MIDIClient(name: "CameraDashboard-ActionsManager")
	}
}
