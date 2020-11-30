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
		throttle(for: .milliseconds(throttleMS), scheduler: DispatchQueue.main, latest: true)
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
	
	enum Response: Equatable {
		static func == (lhs: VISCAClient.Response, rhs: VISCAClient.Response) -> Bool {
			switch (lhs, rhs) {
			case (.finished, .finished):
				return true
			case (.failure, .failure):
				return true
			case (.cancelled, .cancelled):
				return true
			default:
				return false
			}
		}
		
		case finished
		case failure(Swift.Error)
		case cancelled
		
		var error: Swift.Error? {
			switch self {
			case let .failure(error):
				return error
			default:
				return nil
			}
		}
	}
	
	@discardableResult
	private func handle(_ completion: Subscribers.Completion<Swift.Error>) -> Response {
		switch completion {
		case .finished:
			error = nil
			return .finished
		case let .failure(error):
			if error is CommandOverriddenError {
				return .cancelled
			} else {
				self.error = error
				return .failure(error)
			}
		}
	}
	
	// MARK: - Version
	
	@Published var version: VISCAVersion?
	
	func inquireVersion(completion: @escaping (Result<VISCAVersion, Swift.Error>) -> Void) {
		pool.send(inquiry: .version)
			.sink { result in
				if let error = self.handle(result).error {
					completion(.failure(error))
				}
			} receiveValue: { version in
				completion(.success(version))
			}
			.store(in: &observers)
	}
	
	// MARK: - Presets
	
	@Published var preset: RemoteValue<VISCAPreset?> = .init(remote: nil)
	
	func inquirePreset() {
		pool.send(inquiry: .preset)
			.sink { sink in
				self.handle(sink)
			} receiveValue: { value in
				self.preset = .init(remote: value)
			}
			.store(in: &observers)
	}
	
	private func recall(preset: VISCAPreset) {
		pool.send(command: .recall(preset))
			.sink { completion in
				if self.handle(completion) != .cancelled {
					self.inquirePreset()
					self.inquireZoomPosition()
				}
			} receiveValue: { _ in }
			.store(in: &observers)
	}
	
	func set(_ preset: VISCAPreset) {
		pool.send(command: .set(preset))
			.sink { completion in
				if self.handle(completion) == .finished {
					self.preset = .init(remote: preset)
				}
			} receiveValue: { _ in }
			.store(in: &observers)
	}
	
	// MARK: - Zoom
	
	static let maxZoom: UInt16 = 0x6000
	
	@Published var zoomPosition: RemoteValue<UInt16> = .init(remote: 0)
	
	enum ZoomDirection {
		case tele
		case wide
	}
	
	@Published var zoomDirection: ZoomDirection?
	private var zoomTimer: Timer? {
		didSet {
			oldValue?.invalidate()
		}
	}
	
	func inquireZoomPosition() {
		pool.send(inquiry: .zoomPosition)
			.sink { completion in
				if self.handle(completion) != .cancelled, self.zoomDirection != nil {
					self.zoomTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { timer in
						self.inquireZoomPosition()
					})
				}
			} receiveValue: { rawZoom in
				self.zoomPosition = .init(remote: rawZoom)
			}
			.store(in: &observers)
	}
	
	private func setZoom(zoomPosition: UInt16) {
		pool.send(command: .zoomDirect(zoomPosition))
			.sink { completion in
				if self.handle(completion) != .cancelled, self.zoomPosition.local == zoomPosition {
					self.inquireZoomPosition()
				}
			} receiveValue: { _ in
			}
			.store(in: &observers)
	}
	
	private func zoom(_ direction: ZoomDirection?) {
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
			.sink { completion in
				if self.handle(completion) != .cancelled {
					self.inquireZoomPosition()
				}
			} receiveValue: { _ in }
			.store(in: &observers)
	}
	
	// MARK: - Focus
	
	static let maxFocus: UInt16 = 0xF000
	
	@Published var focusPosition: RemoteValue<UInt16> = .init(remote: 0)
	@Published var focusMode: RemoteValue<VISCAFocusMode> = .init(remote: .auto)
	
	enum FocusDirection {
		case far
		case near
	}
	
	@Published var focusDirection: FocusDirection?
	private var focusTimer: Timer? {
		didSet {
			oldValue?.invalidate()
		}
	}
	
	func inquireFocusPosition() {
		pool.send(inquiry: .focusPosition)
			.sink { completion in
				if self.handle(completion) != .cancelled, self.focusDirection != nil {
					self.focusTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false, block: { timer in
						self.inquireFocusPosition()
					})
				}
			} receiveValue: { rawFocus in
				self.focusPosition = .init(remote: rawFocus)
			}
			.store(in: &observers)
	}
	
	func inquireFocusMode() {
		pool.send(inquiry: .focusMode)
			.sink { completion in
				self.handle(completion)
			} receiveValue: { mode in
				self.focusMode = .init(remote: mode)
			}
			.store(in: &observers)
	}
	
	private func setFocus(focusPosition: UInt16) {
		pool.send(command: .focusDirect(focusPosition))
			.sink { completion in
				if self.handle(completion) != .cancelled, self.focusPosition.local == focusPosition {
					self.inquireFocusPosition()
				}
			} receiveValue: { value in
			}
			.store(in: &observers)
	}
	
	private func focus(_ direction: FocusDirection?) {
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
			.sink { completion in
				if self.handle(completion) != .cancelled {
					self.inquireFocusPosition()
				}
			} receiveValue: { _ in }
			.store(in: &observers)
	}
	
	private func set(_ focusMode: VISCAFocusMode) {
		let command: VISCACommand
		switch focusMode {
		case .auto:
			command = .setAutoFocus
		case .manual:
			command = .setManualFocus
		}
		
		pool.send(command: command)
			.sink { completion in
				if self.handle(completion) != .cancelled {
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
			.sink { completion in
				self.handle(completion)
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
