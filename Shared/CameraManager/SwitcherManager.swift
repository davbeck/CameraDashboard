import Combine
import CoreMIDI
import Foundation
import MIDIKit

extension MIDIDevice {
	var isSwitcher: Bool {
		self.manufacturer == "Roland" && self.model == "VR-4HD(MIDI)"
	}
}

class SwitcherClient: ObservableObject, Identifiable {
	private var observers: Set<AnyCancellable> = []

	let device: MIDIDevice
	private let outputPort: MIDIOutputPort
	private let inputPort: MIDIInputPort

	@Published var isOffline: Bool

	let switcher: Switcher

	@Published private(set) var selectedInputNumber: Int? = nil
	var selectedInput: SwitcherInput? {
		guard
			!isOffline,
			let selectedInputNumber,
			switcher.inputs.indices.contains(selectedInputNumber)
		else { return nil }

		return switcher.inputs[selectedInputNumber]
	}

	init(device: MIDIDevice, client: MIDIClient, switcher: Switcher) {
		self.switcher = switcher

		self.device = device
		self.isOffline = device.isOffline
		self.outputPort = try! MIDIOutputPort(client: client, name: "SwitcherClient Output Port")
		self.inputPort = try! MIDIInputPort(client: client, name: "SwitcherClient Input Port")

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
				let endpoints = device.entities.flatMap(\.sources)
				for endpoint in endpoints {
					try! inputPort.connect(source: endpoint)
				}
			}
			.store(in: &observers)

		inputPort.packetRecieved
			.filter { $0.status == .controlChange && $0.control == 0b0000_1110 }
			.map { Int($0.data.2) }
			.receive(on: RunLoop.main)
			.assign(to: &$selectedInputNumber)

		inputPort.packetRecieved
			.sink { packet in
				// assume that any channel we receive on is the channel we should send on
				guard let context = switcher.managedObjectContext else { return }
				context.perform {
					if packet.channel != switcher.channel {
						switcher.channel = packet.channel
						try? context.saveOrRollback()
					}
				}
			}
			.store(in: &observers)
	}

	var id: MIDIUniqueID {
		device.uniqueID
	}

	func connect() {
		let endpoints = device.entities.flatMap(\.sources)
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

		let endpoints = device.entities.flatMap(\.destinations)
		for endpoint in endpoints {
			try! outputPort.send(packet, to: endpoint)
		}
	}

	func select(_ camera: Camera) {
		guard let number = switcher.inputs.firstIndex(where: { $0.camera == camera }) else { return }
		self.send(
			status: .controlChange,
			channel: switcher.channel,
			note: 0b0000_1110,
			intensity: UInt8(number)
		)

		self.selectedInputNumber = number
	}
}

class SwitcherManager: ObservableObject {
	private var observers: Set<AnyCancellable> = []

	let persistentContainer: PersistentContainer

	let client: MIDIClient

	@Published var switchers: [MIDIUniqueID: SwitcherClient] = [:]
	private var switcherObservers: [AnyCancellable] = []
	@Published private var cameraSelections: [MIDIUniqueID: SwitcherInput] = [:]
	var selectedInputs: Set<SwitcherInput> {
		Set(cameraSelections.values)
	}

	static let shared = SwitcherManager(persistentContainer: .shared)

	init(persistentContainer: PersistentContainer) {
		self.persistentContainer = persistentContainer

		self.client = try! MIDIClient(name: "CameraDashboard-SwitcherManager")

		self.client.setupChanged.prepend(())
			.receive(on: RunLoop.main)
			.sink { [weak self] _ in
				guard let self else { return }

				let devices = MIDIDevice.allDevices
					.filter(\.isSwitcher)
				var switchers: [MIDIUniqueID: SwitcherClient] = [:]
				for device in devices {
					if let client = self.switchers[device.uniqueID] {
						switchers[device.uniqueID] = client
					} else {
						let switcher = Switcher.findOrCreate(
							in: persistentContainer.viewContext,
							withMIDIID: device.uniqueID
						)
						let client = SwitcherClient(
							device: device,
							client: self.client,
							switcher: switcher
						)
						switchers[device.uniqueID] = client
					}
				}

				self.cameraSelections = [:]
				self.switcherObservers = switchers.values.map { client in
					client.publisher(for: \.selectedInput)
						.sink { [weak self] selectedInput in
							self?.cameraSelections[client.id] = selectedInput
						}
				}

				self.switchers = switchers
			}
			.store(in: &observers)
	}

	func select(_ camera: Camera) {
		for client in switchers.values {
			client.select(camera)
		}
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
