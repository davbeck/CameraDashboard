import Foundation
import MIDIKit
import Combine
import CoreMIDI

extension ConfigKey {
	static func switcher(id: MIDIUniqueID) -> ConfigKey<[SwitcherClient.Input]> {
		.init(rawValue: "switcher:\(id)", defaultValue: (0..<4).map { _ in .unassigned })
	}
}

extension MIDIDevice {
	var isSwitcher: Bool {
		self.manufacturer == "Roland" && self.model == "VR-4HD(MIDI)"
	}
}

class SwitcherClient: ObservableObject, Identifiable {
	private var observers: Set<AnyCancellable> = []
	
	let configManager: ConfigManager
	
	let device: MIDIDevice
	private let outputPort: MIDIOutputPort
	private let inputPort: MIDIInputPort
	
	@Published var isOffline: Bool = true
	
	enum Input: Hashable, Codable {
		case unassigned
		case camera(UUID)
		
		init(from decoder: Decoder) throws {
			let container = try decoder.singleValueContainer()
			if let id = try? container.decode(UUID.self) {
				self = .camera(id)
			} else {
				self = .unassigned
			}
		}
		
		func encode(to encoder: Encoder) throws {
			var container = encoder.singleValueContainer()
			
			switch self {
			case let .camera(id):
				try container.encode(id)
			case .unassigned:
				try container.encodeNil()
			}
		}
	}
	
	@Published var inputs: [Input] {
		didSet {
			configManager[.switcher(id: device.uniqueID)] = inputs
		}
	}
	
	init(device: MIDIDevice, client: MIDIClient, configManager: ConfigManager = ConfigManager()) {
		self.device = device
		self.outputPort = try! MIDIOutputPort(client: client, name: "SwitcherClient Output Port")
		self.inputPort = try! MIDIInputPort(client: client, name: "SwitcherClient Input Port")
		self.configManager = configManager
		
		self.inputs = configManager[.switcher(id: device.uniqueID)]
		
		client.setupChanged
			.receive(on: RunLoop.main)
			.map { [device] _ in device.isOffline }
			.removeDuplicates()
			.assign(to: &$isOffline)
		
		$isOffline
			.filter { !$0 }
			.removeDuplicates()
			.sink { [inputPort] _ in
				let endpoints = device.entities.flatMap { $0.sources }
				for endpoint in endpoints {
					try! inputPort.connect(source: endpoint)
				}
			}
			.store(in: &observers)
		
		inputPort.packetRecieved
			.receive(on: RunLoop.main)
			.sink { packet in
//				self.receivedPackets.append(packet)
			}
			.store(in: &observers)
	}
	
	var id: MIDIUniqueID {
		device.uniqueID
	}
	
	func connect() {
		let endpoints = device.entities.flatMap { $0.sources }
		for endpoint in endpoints {
			try! inputPort.connect(source: endpoint)
		}
	}
	
	func send(status: MIDIStatus, channel: UInt8, note: UInt8, intensity: UInt8) {
		let packet = MIDIPacket(timeStamp: 0, bytes: [
			status.rawValue | channel,
			note,
			intensity,
		])
		
		let endpoints = device.entities.flatMap { $0.destinations }
		for endpoint in endpoints {
			try! outputPort.send(packet, to: endpoint)
		}
	}
}

class SwitcherManager: ObservableObject {
	private var observers: Set<AnyCancellable> = []
	
	let configManager: ConfigManager
	
	let client: MIDIClient
	
	@Published var switchers: [MIDIUniqueID: SwitcherClient] = [:]
	
	static let shared: SwitcherManager = {
		SwitcherManager(configManager: .shared)
	}()
	
	init(configManager: ConfigManager) {
		self.configManager = configManager
		
		self.client = try! MIDIClient(name: "CameraDashboard-SwitcherManager")
		
		self.client.setupChanged.prepend(())
			.receive(on: RunLoop.main)
			.sink { [weak self] _ in
				guard let self = self else { return }
				
				let devices = MIDIDevice.allDevices
					.filter { $0.isSwitcher }
				var switchers: [MIDIUniqueID: SwitcherClient] = [:]
				for device in devices {
					switchers[device.uniqueID] = self.switchers[device.uniqueID] ?? SwitcherClient(device: device, client: self.client, configManager: configManager)
				}
				
				self.switchers = switchers
			}
			.store(in: &observers)
	}
}
