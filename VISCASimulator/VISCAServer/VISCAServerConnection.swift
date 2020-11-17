import Foundation
import Network

class VISCAServerConnection {
	enum Error: Swift.Error {
		case unrecognizedRequest(Data)
		case unrecognizedCommand(Data)
	}
	
	let camera: Camera
	let connection: NWConnection
	private var sequence: UInt32 = 1
	
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
		print("waiting")
		
		connection.receive(minimumIncompleteLength: 8, maximumLength: 8) { [weak self] data, _, isComplete, error in
			guard let self = self else { return }
			guard let data = data else {
				self.fail(error)
				return
			}
			print("VISCAServerConnection.receive", data.hexDescription)
			
			let command = data.load(offset: 0, as: UInt16.self)
			let size = Int(data.load(offset: 2, as: UInt16.self))
			let sequence = data.load(offset: 4, as: UInt32.self)
			
			print("command", command.hexDescription, size, sequence)
			
			self.connection.receive(minimumIncompleteLength: size, maximumLength: size) { [weak self] data, context, isComplete, error in
				guard let self = self else { return }
				guard let data = data else {
					self.fail(error)
					return
				}
				print("VISCAServerConnection.receive", data.hexDescription)
				
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
			if payload.prefix(4) == Data([0x01, 0x04, 0x3F, 0x02]) {
				let memoryNumber = data[5]
				print("recall", memoryNumber)
				
				Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { timer in
					self.sendCompletion()
				}
			} else if payload.prefix(3) == Data([0x01, 0x04, 0x47]) {
				let zoomPosition = payload.loadBitPadded(offset: 3, as: UInt16.self)
				camera.zoom = zoomPosition
				
				Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { timer in
					self.sendCompletion()
				}
			} else {
				throw Error.unrecognizedCommand(data)
			}
			
			sendAck()
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
			// CAM_ZoomPosInq
			print("zoom", camera.zoom, camera.zoom.bitPadded.hexDescription)
			send(Data([
				0x50,
			]) + camera.zoom.bitPadded)
		} else {
			fail()
		}
	}
	
	private func send(_ data: Data) {
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
}

extension VISCAServerConnection: Hashable {
	static func == (lhs: VISCAServerConnection, rhs: VISCAServerConnection) -> Bool {
		return lhs === rhs
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(ObjectIdentifier(self))
	}
}
