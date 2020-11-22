import Foundation
import Network
import Combine

extension NWEndpoint.Port {
	static var visca: NWEndpoint.Port {
		5678
	}
}

let throttleMS = 100

extension Publisher {
	func viscaThrottle() -> Publishers.Throttle<Self, DispatchQueue> {
		throttle(for: .milliseconds(throttleMS), scheduler: DispatchQueue.visca, latest: true)
	}
}

extension Publisher where Failure == Never {
	func filterUserEvents<T>() -> AnyPublisher<T, Never> where Output == VISCAClient.RemoteValue<T> {
		filter { $0.needsUpdate }
			.compactMap { $0.local }
			.removeDuplicates()
			.viscaThrottle()
			.eraseToAnyPublisher()
	}
	
	func filterUserEvents<T>() -> AnyPublisher<T, Never> where Output == VISCAClient.RemoteValue<T?> {
		filter { $0.needsUpdate }
			.compactMap { $0.local }
			.removeDuplicates()
			.viscaThrottle()
			.eraseToAnyPublisher()
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
		
		$preset
			.filterUserEvents()
			.sink { [weak self] value in
				self?.recall(preset: value)
			}
			.store(in: &observers)
		
		$zoomPosition
			.filterUserEvents()
			.sink { [weak self] zoomPosition in
				self?.setZoom(zoomPosition: zoomPosition)
			}
			.store(in: &observers)
		$zoomDirection
			.dropFirst()
			.removeDuplicates()
			.viscaThrottle()
			.sink { [weak self] value in
				self?.zoom(value)
			}
			.store(in: &observers)
		
		$focusPosition
			.filterUserEvents()
			.sink { [weak self] value in
				self?.setFocus(focusPosition: value)
			}
			.store(in: &observers)
		$focusDirection
			.dropFirst()
			.removeDuplicates()
			.viscaThrottle()
			.sink { [weak self] value in
				self?.focus(value)
			}
			.store(in: &observers)
		$focusMode
			.filterUserEvents()
			.sink { [weak self] value in
				self?.set(value)
			}
			.store(in: &observers)
		
		$vector
			.dropFirst()
			.removeDuplicates()
			.viscaThrottle()
			.sink { [weak self] value in
				self?.updateVector(vector: value)
			}
			.store(in: &observers)
	}
	
	func stop() {
		pool.stop()
	}
	
	struct RemoteValue<T: Equatable>: Equatable {
		var remote: T
		var local: T
		
		init(remote: T) {
			self.remote = remote
			local = remote
		}
		
		var needsUpdate: Bool {
			return local != remote
		}
	}
	
	@Published var error: Swift.Error?
	
	// MARK: - Version
	
	@Published var version: VISCAVersion?
	
	func inquireVersion(completion: @escaping (Result<VISCAVersion, Swift.Error>) -> Void) {
		pool.send(inquiry: .version)
			.receive(on: RunLoop.main)
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
	
	@Published var preset: RemoteValue<VISCAPreset?> = .init(remote: nil)
	
	private func recall(preset: VISCAPreset) {
		pool.send(command: .recall(preset))
			.receive(on: DispatchQueue.main)
			.sink { completion in
				switch completion {
				case .finished:
					if self.preset.local == preset {
						self.preset.remote = preset
					}
					self.error = nil
				case let .failure(error):
					if self.preset.local == preset {
						self.preset.local = nil
					}
					self.error = error
				}
			} receiveValue: { _ in }
			.store(in: &observers)
	}
	
	// MARK: - Zoom
	
	@Published var zoomPosition: RemoteValue<UInt16> = .init(remote: 0)
	
	enum ZoomDirection {
		case tele
		case wide
	}
	
	@Published var zoomDirection: ZoomDirection?
	
	func inquireZoomPosition(completion: ((Result<Double, Swift.Error>) -> Void)? = nil) {
		print("inquireZoomPosition")
		pool.send(inquiry: .zoomPosition)
			.receive(on: DispatchQueue.main)
			.sink { sink in
				switch sink {
				case .finished:
					break
				case let .failure(error):
					completion?(.failure(error))
				}
			} receiveValue: { rawZoom in
				let zoom = Double(rawZoom) / Double(UInt16.max)
				self.zoomPosition = .init(remote: rawZoom)
				completion?(.success(zoom))
			}
			.store(in: &observers)
	}
	
	private func setZoom(zoomPosition: UInt16, completion: ((Result<Void, Swift.Error>) -> Void)? = nil) {
		print("setZoom", zoomPosition, zoomPosition.hexDescription)
		pool.send(command: .zoomDirect(zoomPosition))
			.receive(on: RunLoop.main)
			.sink { sink in
				switch sink {
				case .finished:
					if self.zoomPosition.local == zoomPosition {
						self.zoomPosition.remote = zoomPosition
					}
					
					completion?(.success(()))
				case let .failure(error):
					completion?(.failure(error))
				}
			} receiveValue: { _ in
			}
			.store(in: &observers)
	}
	
	private var zoomUpdateTimer: Timer? {
		didSet {
			oldValue?.invalidate()
		}
	}
	
	private func zoom(_ direction: ZoomDirection?) {
		print("zoom", direction as Any)
		let command: VISCACommand
		switch direction {
		case .tele:
			command = .zoomTele
		case .wide:
			command = .zoomWide
		case .none:
			command = .zoomStop
		}
		
		pool.send(command: command)
			.handleEvents(receiveCompletion: { completion in
				switch direction {
				case .tele, .wide:
					print("zoomUpdateTimer")
					self.zoomUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { timer in
						self.inquireZoomPosition()
					})
				case .none:
					self.zoomUpdateTimer = nil
					self.inquireZoomPosition()
				}
			})
			.receive(on: RunLoop.main)
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
	
	// MARK: - Focus
	
	@Published var focusPosition: RemoteValue<UInt16> = .init(remote: 0)
	@Published var focusMode: RemoteValue<VISCAFocusMode> = .init(remote: .auto)
	
	enum FocusDirection {
		case far
		case near
	}
	
	@Published var focusDirection: FocusDirection?
	
	func inquireFocusPosition(completion: ((Result<Double, Swift.Error>) -> Void)? = nil) {
		print("inquireFocusPosition")
		pool.send(inquiry: .focusPosition)
			.receive(on: RunLoop.main)
			.sink { sink in
				switch sink {
				case .finished:
					break
				case let .failure(error):
					completion?(.failure(error))
				}
			} receiveValue: { rawFocus in
				let focus = Double(rawFocus) / Double(UInt16.max)
				self.focusPosition = .init(remote: rawFocus)
				completion?(.success(focus))
			}
			.store(in: &observers)
	}
	
	func inquireFocusMode() {
		print("inquireFocusMode")
		pool.send(inquiry: .focusMode)
			.receive(on: RunLoop.main)
			.sink { sink in
			} receiveValue: { mode in
				self.focusMode = .init(remote: mode)
			}
			.store(in: &observers)
	}
	
	private func setFocus(focusPosition: UInt16, completion: ((Result<Void, Swift.Error>) -> Void)? = nil) {
		print("setFocus", focusPosition, focusPosition.hexDescription)
		pool.send(command: .focusDirect(focusPosition))
			.receive(on: RunLoop.main)
			.sink { sink in
				switch sink {
				case .finished:
					if self.focusPosition.local == focusPosition {
						self.focusPosition.remote = focusPosition
					}
					
					completion?(.success(()))
				case let .failure(error):
					completion?(.failure(error))
				}
			} receiveValue: { _ in
			}
			.store(in: &observers)
	}
	
	private var focusUpdateTimer: Timer? {
		didSet {
			oldValue?.invalidate()
		}
	}
	
	private func focus(_ direction: FocusDirection?) {
		print("focus", direction as Any)
		let command: VISCACommand
		switch direction {
		case .far:
			command = .focusTele
		case .near:
			command = .focusWide
		case .none:
			command = .focusStop
		}
		
		pool.send(command: command)
			.receive(on: RunLoop.main)
			.sink { completion in
				switch completion {
				case let .failure(error):
					self.error = error
				case .finished:
					self.error = nil
				}
				
				switch direction {
				case .far, .near:
					self.focusUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { timer in
						self.inquireFocusPosition()
					})
				case .none:
					self.focusUpdateTimer = nil
					self.inquireFocusPosition()
				}
			} receiveValue: { _ in }
			.store(in: &observers)
	}
	
	private func set(_ focusMode: VISCAFocusMode) {
		print("focusMode", focusMode)
		let command: VISCACommand
		switch focusMode {
		case .auto:
			command = .setAutoFocus
		case .manual:
			command = .setManualFocus
		}
		
		pool.send(command: command)
			.receive(on: RunLoop.main)
			.sink { completion in
				switch completion {
				case let .failure(error):
					self.error = error
				case .finished:
					self.error = nil
				}
				
				switch focusMode {
				case .auto:
					self.focusUpdateTimer = nil
				case .manual:
					self.inquireFocusPosition()
				}
			} receiveValue: { _ in }
			.store(in: &observers)
	}
	
	// MARK: - PTZ
	
	@Published var vector: PTZVector?
	
	static let vectorSpeedKey: String = defaultsKey("VISCAClient.vectorSpeed", default: 0.5)
	var vectorSpeed: Double {
		return UserDefaults.standard.double(forKey: Self.vectorSpeedKey)
	}
	
	private func updateVector(vector: PTZVector?) {
		let command: VISCACommand
		
		switch vector {
		case let .direction(direction):
			command = .panTilt(
				direction: direction,
				panSpeed: UInt8(vectorSpeed * 0x18),
				tiltSpeed: UInt8(vectorSpeed * 0x18)
			)
		case let .relative(angle: angle, speed: speed):
			let x = cos(angle.radians)
			let y = sin(angle.radians)
			
			// use speed to control angle
			let panSpeed = UInt8(vectorSpeed * speed * 0x18 * abs(x))
			let tiltSpeed = UInt8(vectorSpeed * speed * 0x18 * abs(y))
			
			// pick a direction based on quadrant
			switch (x > 0, y > 0) {
			case (true, true): // downRight
				command = .panTilt(
					direction: .downRight,
					panSpeed: panSpeed,
					tiltSpeed: tiltSpeed
				)
			case (true, false): // upRight
				command = .panTilt(
					direction: .upRight,
					panSpeed: panSpeed,
					tiltSpeed: tiltSpeed
				)
			case (false, true): // downLeft
				command = .panTilt(
					direction: .downLeft,
					panSpeed: panSpeed,
					tiltSpeed: tiltSpeed
				)
			case (false, false): // upLeft
				command = .panTilt(
					direction: .upLeft,
					panSpeed: panSpeed,
					tiltSpeed: tiltSpeed
				)
			}
		case .none:
			print("panTiltStop")
			command = .panTiltStop
		}
		
		pool.send(command: command)
			.receive(on: RunLoop.main)
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
