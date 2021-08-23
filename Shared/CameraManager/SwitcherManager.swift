import Foundation
import MIDIKit
import Combine
import CoreMIDI

extension ConfigKey {
	static func switcher(id: MIDIUniqueID) -> ConfigKey<[SwitcherClient.Input]> {
		.init(rawValue: "switcher:\(id)", defaultValue: (0..<4).map { _ in .unassigned })
	}

	static func switcherChannel(id: MIDIUniqueID) -> ConfigKey<MIDIChannelNumber> {
		.init(rawValue: "switcher:channel:\(id)", defaultValue: 0)
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
		
		var cameraID: UUID? {
			switch self {
			case .unassigned:
				return nil
			case let .camera(id):
				return id
			}
		}
	}
	
	@Published var inputs: [Input] {
		didSet {
			configManager[.switcher(id: device.uniqueID)] = inputs
		}
	}
	
	@Published var channel: MIDIChannelNumber {
		didSet {
			configManager[.switcherChannel(id: device.uniqueID)] = channel
		}
	}

	@Published private(set) var selectedInput: Int? = nil
	var selectedCameraID: UUID? {
		guard
			!isOffline,
			let selectedInput = selectedInput,
			inputs.indices.contains(selectedInput)
		else { return nil }
		
		switch inputs[selectedInput] {
		case .unassigned:
			return nil
		case let .camera(id):
			return id
		}
	}
	
	init(device: MIDIDevice, client: MIDIClient, configManager: ConfigManager = ConfigManager()) {
		self.device = device
		self.outputPort = try! MIDIOutputPort(client: client, name: "SwitcherClient Output Port")
		self.inputPort = try! MIDIInputPort(client: client, name: "SwitcherClient Input Port")
		self.configManager = configManager
		
		self.inputs = configManager[.switcher(id: device.uniqueID)]
		self.channel = configManager[.switcherChannel(id: device.uniqueID)]
		
		client.propertyChanged
			.filter { $0.propertyName.takeUnretainedValue() == kMIDIPropertyOffline }
			.map { [device] _ in device.isOffline }
			.removeDuplicates()
			.receive(on: RunLoop.main)
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
			.filter { $0.status == .controlChange && $0.control == 0b0000_1110 }
			.map { Int($0.data.2) }
			.receive(on: RunLoop.main)
			.assign(to: &$selectedInput)
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
	
	func selectCamera(id: UUID) {
		guard let number = inputs.firstIndex(of: .camera(id)) else { return }
		self.send(
			status: .controlChange,
			channel: channel,
			note: 0b0000_1110,
			intensity: UInt8(number)
		)
		
		self.selectedInput = number
	}
}

class SwitcherManager: ObservableObject {
	private var observers: Set<AnyCancellable> = []
	
	let configManager: ConfigManager
	
	let client: MIDIClient
	
	@Published var switchers: [MIDIUniqueID: SwitcherClient] = [:]
	private var switcherObservers: [AnyCancellable] = []
	@Published private var cameraSelections: [MIDIUniqueID: UUID] = [:]
	var selectedCameraIDs: Set<UUID> {
		Set(cameraSelections.values)
	}
	
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
					if let client = self.switchers[device.uniqueID] {
						switchers[device.uniqueID] = client
					} else {
						let client = SwitcherClient(device: device, client: self.client, configManager: configManager)
						client.publisher(for: \.selectedCameraID)
							.sink { [weak self] cameraID in
								self?.cameraSelections[device.uniqueID] = cameraID
							}
							.store(in: &self.observers)
						switchers[device.uniqueID] = client
					}
				}
				
				self.cameraSelections = [:]
				self.switcherObservers = switchers.values.map { client in
					client.publisher(for: \.selectedCameraID)
						.sink { [weak self] id in
							self?.cameraSelections[client.id] = id
						}
				}
				
				self.switchers = switchers
			}
			.store(in: &observers)
	}
	
	func selectCamera(id: UUID) {
		switchers.values
			.first(where: { $0.inputs.contains(where: { $0.cameraID == id }) })?
			.selectCamera(id: id)
	}
}

extension ObservableObject {
	func publisher<Value>(for keyPath: KeyPath<Self, Value>) -> AnyPublisher<Value, Never> {
		self.objectWillChange
			.throttle(for: 0, scheduler: RunLoop.main, latest: true)
			.compactMap { [weak self] _ in self?[keyPath: keyPath] }
			.prepend(self[keyPath: keyPath])
			.eraseToAnyPublisher()
	}
}
