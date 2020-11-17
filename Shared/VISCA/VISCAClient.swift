import Foundation
import Network
import Combine

extension NWEndpoint.Port {
	static var visca: NWEndpoint.Port {
		5678
	}
}

class VISCAClient: ObservableObject {
	enum Error: Swift.Error, LocalizedError {
		case invalidInitialResponseByte
		case unexpectedBytes
		case missingAck
		case missingCompletion
		case notReady
		case timeout
		
		var errorDescription: String? {
			switch self {
			case .invalidInitialResponseByte:
				return "Received an invalid response from the camera."
			case .unexpectedBytes:
				return "Received unexpected data from the camera."
			case .missingAck:
				return "The camera did not respond."
			case .missingCompletion:
				return "The camera did not respond after updating."
			case .notReady:
				return "The camera is not connected."
			case .timeout:
				return "The operation timed out."
			}
		}
	}
	
	private var observers: Set<AnyCancellable> = []
	
	let pool: VISCAPool
	
	init(host: NWEndpoint.Host, port: NWEndpoint.Port) {
		pool = VISCAPool(host: host, port: port)
	}
	
	func stop() {
		pool.stop()
	}
	
	@Published var error: Swift.Error?
	
	// MARK: - Version
	
	@Published var version: VISCAVersion?
	
	func inquireVersion(completion: @escaping (Result<VISCAVersion, Swift.Error>) -> Void) {
		pool.aquire { connection in
			connection.sendVISCAInquiry(payload: Data([0x09, 0x00, 0x02]))
				.eraseToAnyPublisher()
		}
		.tryMap { (data) -> VISCAVersion in
			guard data.count == 8 else { throw Error.unexpectedBytes }
			
			let venderID = data.load(offset: 1, as: UInt16.self)
			let modelID = data.load(offset: 3, as: UInt16.self)
			let armVersion = data.load(offset: 5, as: UInt16.self)
			let reserve = data.load(offset: 7, as: UInt8.self)
			
			return VISCAVersion(
				venderID: venderID,
				modelID: modelID,
				armVersion: armVersion,
				reserve: reserve
			)
		}
		.sink { result in
			switch result {
			case let .failure(error):
				completion(.failure(error))
			case .finished:
				break
			}
		} receiveValue: { version in
			completion(.success(version))
		}
		.store(in: &observers)
	}
	
	// MARK: - Presets
	
	@Published var currentPreset: VISCAPreset?
	@Published var nextPreset: VISCAPreset?
	
	func recall(preset: VISCAPreset) {
		nextPreset = preset
		
		pool.aquire { connection in
			connection.sendVISCACommand(payload: Data([0x01, 0x04, 0x3F, 0x02, preset.rawValue]))
				.eraseToAnyPublisher()
		}
		.sink { completion in
			switch completion {
			case .finished:
				self.currentPreset = preset
				self.error = nil
			case let .failure(error):
				self.nextPreset = nil
				self.error = error
			}
		} receiveValue: { _ in }
		.store(in: &observers)
	}
	
	// MARK: - Zoom
	
	@Published var zoomPosition: Double = 0 {
		didSet {
			setZoom(zoomPosition: UInt16(zoomPosition * Double(UInt16.max)))
		}
	}
	
	func inquireZoomPosition(completion: ((Result<Double, Swift.Error>) -> Void)? = nil) {
		pool.sendVISCAInquiry(payload: Data([0x09, 0x04, 0x47]))
			.sink { sink in
				switch sink {
				case .finished:
					break
				case let .failure(error):
					completion?(.failure(error))
				}
			} receiveValue: { data in
				let rawZoom = data.loadBitPadded(offset: 1, as: UInt16.self)
				let zoom = Double(rawZoom) / Double(UInt16.max)
				self.zoomPosition = zoom
				completion?(.success(zoom))
			}
			.store(in: &observers)
	}
	
	func setZoom(zoomPosition: UInt16, completion: ((Result<Void, Swift.Error>) -> Void)? = nil) {
		pool.sendVISCACommand(payload: Data([0x01, 0x04, 0x47]) + zoomPosition.bitPadded)
			.sink { sink in
				switch sink {
				case .finished:
					completion?(.success(()))
				case let .failure(error):
					completion?(.failure(error))
				}
			} receiveValue: { data in }
			.store(in: &observers)
	}
	
	// MARK: - PTZ
	
	@Published var vector: PTZVector? {
		didSet {
			updateVector()
		}
	}
	
	static let vectorSpeedKey: String = defaultsKey("VISCAClient.vectorSpeed", default: 0.5)
	
	var vectorSpeed: Double {
		return UserDefaults.standard.double(forKey: Self.vectorSpeedKey)
	}
	
	@Published var vectorError: Swift.Error?
	
	private var needsVectorUpdate: Bool = false
	
	private func updateVector() {
		guard !needsVectorUpdate else { return }
		needsVectorUpdate = true
		
		pool.aquire { [weak self] (connection) -> AnyPublisher<Void, Swift.Error> in
			guard let self = self else {
				return Fail(error: Error.notReady)
					.eraseToAnyPublisher()
			}
			self.needsVectorUpdate = false
			var payload = Data([0x01, 0x06])
			
			switch self.vector {
			case let .direction(direction):
				payload.append(0x01)
				payload.append(UInt8(self.vectorSpeed * 0x18)) // pan speed 0x01 - 0x18
				payload.append(UInt8(self.vectorSpeed * 0x18)) // tilt speed 0x01 - 0x14
				
				switch direction {
				case .up:
					payload.append(contentsOf: [0x03, 0x01])
				case .upRight:
					payload.append(contentsOf: [0x02, 0x01])
				case .right:
					payload.append(contentsOf: [0x02, 0x03])
				case .downRight:
					payload.append(contentsOf: [0x02, 0x02])
				case .down:
					payload.append(contentsOf: [0x03, 0x02])
				case .downLeft:
					payload.append(contentsOf: [0x01, 0x02])
				case .left:
					payload.append(contentsOf: [0x01, 0x03])
				case .upLeft:
					payload.append(contentsOf: [0x01, 0x01])
				}
			case let .relative(angle: angle, speed: speed):
				let x = cos(angle.radians)
				let y = sin(angle.radians)
				
				payload.append(0x01)
				
				// use speed to control angle
				payload.append(UInt8(self.vectorSpeed * speed * 0x18 * abs(x))) // pan speed 0x01 - 0x18
				payload.append(UInt8(self.vectorSpeed * speed * 0x18 * abs(y))) // tilt speed 0x01 - 0x14
				
				// pick a direction based on quadrant
				switch (x > 0, y > 0) {
				case (true, true): // downRight
					payload.append(contentsOf: [0x02, 0x02])
				case (true, false): // upRight
					payload.append(contentsOf: [0x02, 0x01])
				case (false, true): // downLeft
					payload.append(contentsOf: [0x01, 0x02])
				case (false, false): // upLeft
					payload.append(contentsOf: [0x01, 0x01])
				}
			case .none:
				// cancel
				payload.append(0x01)
				payload.append(UInt8(self.vectorSpeed * 0x18)) // pan speed 0x01 - 0x18
				payload.append(UInt8(self.vectorSpeed * 0x18)) // tilt speed 0x01 - 0x14
				payload.append(contentsOf: [0x03, 0x03])
			}
			
			return connection.sendVISCACommand(payload: payload)
		}
		.sink { completion in
			switch completion {
			case let .failure(error):
				self.error = error
			case .finished:
				self.error = nil
			}
		} receiveValue: { _ in }
		.store(in: &observers)
	}
}

extension VISCAClient: Hashable {
	static func == (lhs: VISCAClient, rhs: VISCAClient) -> Bool {
		return lhs === rhs
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(ObjectIdentifier(self))
	}
}
