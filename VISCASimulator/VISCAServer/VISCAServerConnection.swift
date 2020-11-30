import Foundation
import Network
import Combine

class VISCAServerConnection {
	enum Error: Swift.Error {
		case unrecognizedRequest(Data)
		case unrecognizedCommand(Data)
	}
	
	private var observers: Set<AnyCancellable> = []
	
	let camera: Camera
	let connection: NWConnection
	private var sequence: UInt32 = 1
	
	var isActive: Bool = true
	
	var didStopCallback: ((VISCAServerConnection, Swift.Error?) -> Void)?
	
	init(camera: Camera, connection: NWConnection) {
		self.camera = camera
		self.connection = connection
		
		connection.stateUpdateHandler = { [weak self] state in
			print("VISCAServerConnection.stateUpdateHandler", state)
			guard let self = self else { return }
			switch state {
			case .cancelled:
				self.didStopCallback?(self, nil)
			case let .waiting(error), let .failed(error):
				self.didStopCallback?(self, error)
			case .ready:
				self.receive()
			default:
				break
			}
		}
		connection.start(queue: .main)
	}
	
	private func fail(_ error: Swift.Error? = nil) {
		print("fail", error as Any)
		connection.cancel()
	}
	
	private func receive() {
		connection.receive(minimumIncompleteLength: 8, maximumLength: 8) { [weak self] data, _, isComplete, error in
			guard let self = self else { return }
			guard let data = data else {
				self.fail(error)
				return
			}
//			print("⬇️📦", data.hexDescription)
			
			let command = data.load(offset: 0, as: UInt16.self)
			let size = Int(data.load(offset: 2, as: UInt16.self))
			let sequence = data.load(offset: 4, as: UInt32.self)
			// TODO: Send error if these don't match
			self.sequence = sequence + 1
			
//			print("command", command.hexDescription, size, sequence)
			
			self.connection.receive(minimumIncompleteLength: size, maximumLength: size) { [weak self] data, context, isComplete, error in
				guard let self = self else { return }
				guard let data = data else {
					self.fail(error)
					return
				}
				print("⬇️", data.hexDescription)
				
				switch command {
				case 0x0100:
					self.handleViscaCommand(data)
				case 0x0110:
					self.handleViscaInquiry(data)
				case 0x0200:
					self.handleControlCommand(data)
				default:
					self.fail()
				}
				
				self.receive()
			}
		}
	}
	
	private func handleControlCommand(_ data: Data) {
		if data == Data([0x01]) {
			print("resetting sequence")
			sequence = 1
		}
	}
	
	private func handleViscaCommand(_ data: Data) {
		do {
			let payload = data.dropFirst().dropLast()
			
			if payload.prefix(4) == Data([0x01, 0x04, 0x3F, 0x02]), let memoryNumber = payload.dropFirst(4).first {
				print("recall", memoryNumber)
				
				guard let preset = camera.presets[memoryNumber] else {
					sendNotExecutable()
					return
				}
				camera.preset = memoryNumber
				
				camera.zoom.destination = .init(direction: .direct(preset.zoom), speed: 0x0F * 5)
				camera.pan.destination = .init(direction: .direct(preset.pan), speed: 0x18 * 10)
				camera.tilt.destination = .init(direction: .direct(preset.tilt), speed: 0x14 * 10)
				
				sendAck()
				
				let pan = camera.pan.$destination
					.dropFirst()
					.first()
				
				let tilt = camera.tilt.$destination
					.dropFirst()
					.first()
				
				let zoom = camera.tilt.$destination
					.dropFirst()
					.first()
				
				pan
					.combineLatest(tilt)
					.combineLatest(zoom)
					.sink { _ in
						self.sendCompletion()
					}
					.store(in: &observers)
			} else if payload.prefix(4) == Data([0x01, 0x04, 0x3F, 0x01]), let memoryNumber = payload.dropFirst(4).first {
				print("set preset", memoryNumber)
				camera.presets[memoryNumber] = Preset(
					pan: camera.pan.value,
					tilt: camera.tilt.value,
					zoom: camera.zoom.value
				)
				camera.preset = memoryNumber
				
				sendAck()
				sendCompletion()
			} else if payload.prefix(3) == Data([0x01, 0x06, 0x01]),
				let panSpeed = payload.dropFirst(3).first,
				let tiltSpeed = payload.dropFirst(4).first,
				let panDirection = payload.dropFirst(5).first,
				let tiltDirection = payload.dropFirst(6).first {
				print("pantilt", panDirection, tiltDirection)
				
				switch panDirection {
				case 0x01:
					camera.pan.destination = .init(direction: .down, speed: Int(panSpeed) * 10)
				case 0x02:
					camera.pan.destination = .init(direction: .up, speed: Int(panSpeed) * 10)
				case 0x03:
					camera.pan.destination = nil
				default:
					sendError()
				}
				
				switch tiltDirection {
				case 0x01:
					camera.tilt.destination = .init(direction: .up, speed: Int(tiltSpeed) * 10)
				case 0x02:
					camera.tilt.destination = .init(direction: .down, speed: Int(tiltSpeed) * 10)
				case 0x03:
					camera.tilt.destination = nil
				default:
					sendError()
				}
				
				sendAck()
				sendCompletion()
			} else if payload.prefix(3) == Data([0x01, 0x04, 0x47]) {
				var zoomPosition = payload.loadBitPadded(offset: 3, as: UInt16.self)
				print("setting zoom", zoomPosition)
				zoomPosition = min(zoomPosition, UInt16(camera.zoom.maxValue))
				camera.zoom.destination = .init(direction: .direct(Int(zoomPosition)), speed: 0x0F * 5)
				
				sendAck()
				camera.zoom.$destination
					.dropFirst()
					.first()
					.sink { _ in
						self.sendCompletion()
					}
					.store(in: &observers)
			} else if payload.prefix(3) == Data([0x01, 0x04, 0x07]), let directionBit = payload.dropFirst(3).first {
				print("zoom", directionBit.hexDescription)
				switch directionBit {
				case 0x00:
					camera.zoom.destination = nil
				case 0x02:
					camera.zoom.destination = .init(direction: .up, speed: 0x0F * 5)
				case 0x03:
					camera.zoom.destination = .init(direction: .down, speed: 0x0F * 5)
				default:
					throw Error.unrecognizedCommand(data)
				}
				
				sendAck()
				sendCompletion()
			} else if payload.prefix(3) == Data([0x01, 0x04, 0x48]) {
				var position = payload.dropFirst(3).loadBitPadded(as: UInt16.self)
				print("CAM_Focus Direct", position)
				position = min(position, UInt16(camera.focus.maxValue))
				camera.focus.destination = .init(direction: .direct(Int(position)), speed: 0x0F)
				
				sendAck()
				camera.focus.$destination
					.dropFirst()
					.first()
					.sink { _ in
						self.sendCompletion()
					}
					.store(in: &observers)
			} else if payload.prefix(3) == Data([0x01, 0x04, 0x08]), let directionBit = payload.dropFirst(3).first {
				print("CAM_Focus", directionBit.hexDescription)
				switch directionBit {
				case 0x00:
					camera.focus.destination = nil
				case 0x02:
					camera.focus.destination = .init(direction: .up, speed: 0x0F)
				case 0x03:
					camera.focus.destination = .init(direction: .down, speed: 0x0F)
				default:
					throw Error.unrecognizedCommand(data)
				}
				
				sendAck()
				sendCompletion()
			} else if payload.prefix(3) == Data([0x01, 0x04, 0x38]), let modeBit = payload.dropFirst(3).first {
				print("CAM_Focus Mode", modeBit.hexDescription)
				switch modeBit {
				case 0x02:
					camera.focusIsAuto = true
				case 0x03:
					camera.focusIsAuto = false
				default:
					throw Error.unrecognizedCommand(data)
				}
				
				sendAck()
				sendCompletion()
			} else {
				throw Error.unrecognizedCommand(data)
			}
		} catch {
			sendError()
		}
	}
	
	private func handleViscaInquiry(_ data: Data) {
		let payload = data.dropFirst().dropLast()
		if payload == Data([0x09, 0x00, 0x02]) {
			send(Data([
				0x50,
				0x02, 0x20,
				0x09, 0x50,
				0x00, 0x01,
				0x00,
			]))
		} else if payload == Data([0x09, 0x04, 0x47]) {
			print("CAM_ZoomPosInq", camera.zoom, camera.zoom.value.bitPadded.hexDescription)
			send(Data([
				0x50,
			]) + UInt16(camera.zoom.value).bitPadded)
		} else if payload == Data([0x09, 0x04, 0x3F]) {
			print("CAM_MemoryInq", camera.preset, camera.preset.hexDescription)
			send(Data([
				0x50, camera.preset,
			]))
		} else if payload == Data([0x09, 0x04, 0x38]) {
			print("CAM_FocusAFModeInq", camera.focusIsAuto)
			send(Data([
				0x50,
				camera.focusIsAuto ? 0x02 : 0x03,
			]))
		} else if payload == Data([0x09, 0x04, 0x48]) {
			print("CAM_FocusPosInq", camera.focus)
			send(Data([
				0x50,
			]) + UInt16(camera.focus.value).bitPadded)
		} else {
			fail()
		}
	}
	
	private func send(_ data: Data) {
		guard isActive else {
			print("not sending response")
			return
		}
		
		print("sending", data.hexDescription)
		connection.send(content: [0x90] + data + [0xFF], completion: .contentProcessed { error in
			if let error = error {
				self.fail(error)
			}
		})
	}
	
	private func sendAck() {
		send(Data([0x41]))
	}
	
	private func sendCompletion() {
		send(Data([0x51]))
	}
	
	private func sendError() {
		send(Data([0x60, 0x02]))
	}
	
	private func sendNotExecutable() {
		send(Data([0x61, 0x41]))
	}
}

extension VISCAServerConnection: Hashable {
	static func == (lhs: VISCAServerConnection, rhs: VISCAServerConnection) -> Bool {
		return lhs === rhs
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(ObjectIdentifier(self))
	}
}

extension VISCAServerConnection: Identifiable {
	var id: ObjectIdentifier {
		return ObjectIdentifier(self)
	}
}
