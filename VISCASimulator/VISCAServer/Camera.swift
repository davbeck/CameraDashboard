import Foundation
import Defaults

struct Preset: Codable {
	var pan: Int
	var tilt: Int
	var zoom: Int
}

extension Defaults.Keys {
	static let preset = Key<UInt8>("Camera.preset", default: 0)
	static let presets = Key<[UInt8: Preset]>("Camera.presets", default: [:])
	static let pan = Key<Int>("Camera.pan", default: 0)
	static let tilt = Key<Int>("Camera.tilt", default: 0)
	static let zoom = Key<Int>("Camera.zoom", default: 0)
	static let focus = Key<Int>("Camera.focus", default: 0)
	static let focusIsAuto = Key<Bool>("Camera.focusIsAuto", default: true)
}

let updateInterval: TimeInterval = 0.01

final class Camera: ObservableObject {
	// MARK: - Preset
	
	@Published var presets: [UInt8: Preset] = Defaults[.presets] {
		didSet {
			Defaults[.presets] = presets
		}
	}
	
	@Published var preset: UInt8 = Defaults[.preset] {
		didSet {
			Defaults[.preset] = preset
		}
	}
	
	// MARK: - Pan Tilt
	
	let maxPan = 0x52EF
	let minPan = -0x52EF
	
	@Published var pan: Int = Defaults[.pan] {
		didSet {
			Defaults[.pan] = pan
		}
	}
	
	let minTilt = -0x1BA5
	let maxTilt = 0x52EF
	
	@Published var tilt: Int = Defaults[.tilt] {
		didSet {
			Defaults[.tilt] = tilt
		}
	}
	
	struct PanTiltDestination: Equatable {
		enum Direction: Equatable {
			case direct(pan: Int, tilt: Int)
			case up
			case upRight
			case right
			case downRight
			case down
			case downLeft
			case left
			case upLeft
		}
		
		var direction: Direction
		var panSpeed: UInt8
		var tiltSpeed: UInt8
	}
	
	private var panTiltTimer: Timer? {
		didSet {
			oldValue?.invalidate()
		}
	}
	
	@Published var panTiltDestination: PanTiltDestination? {
		didSet {
			if let panTiltDestination = panTiltDestination {
				// zoom from min to max in x seconds
				let panStep = Int(panTiltDestination.panSpeed) * 10
				let tiltStep = Int(panTiltDestination.panSpeed) * 10
				
				panTiltTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true, block: { [weak self] timer in
					guard let self = self else {
						timer.invalidate()
						return
					}
					
					switch panTiltDestination.direction {
					case let .direct(pan: pan, tilt: tilt):
						if pan > self.pan {
							self.pan = min(self.pan + panStep, pan)
						} else {
							self.pan = max(self.pan - panStep, pan)
						}
						
						if tilt > self.tilt {
							self.tilt = min(self.tilt + tiltStep, tilt)
						} else {
							self.tilt = max(self.tilt - tiltStep, tilt)
						}
						
						if pan == self.pan, tilt == self.tilt {
							self.panTiltDestination = nil
						}
					default:
						break
					}
				})
			} else {
				panTiltTimer = nil
			}
		}
	}
	
	// MARK: - Zoom
	
	let maxZoom = 0x4000
	@Published var zoom: Int = Defaults[.zoom] {
		didSet {
			Defaults[.zoom] = zoom
		}
	}
	
	enum ZoomDestination: Equatable {
		case direct(Int)
		case tele
		case wide
	}
	
	private var zoomTimer: Timer? {
		didSet {
			oldValue?.invalidate()
		}
	}
	
	@Published var zoomDestination: ZoomDestination? {
		didSet {
			if let zoomDestination = zoomDestination {
				// zoom from min to max in x seconds
				let step = Int(Double(maxZoom) / 3 * updateInterval)
				
				zoomTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true, block: { [weak self] timer in
					guard let self = self else {
						timer.invalidate()
						return
					}
					
					switch zoomDestination {
					case let .direct(destination):
						if destination > self.zoom {
							self.zoom = min(self.zoom + step, destination)
						} else {
							self.zoom = max(self.zoom - step, destination)
						}
						
						if destination == self.zoom {
							self.zoomDestination = nil
						}
					case .wide:
						self.zoom = max(self.zoom - step, 0)
						
						if self.zoom == 0 {
							self.zoomDestination = nil
						}
					case .tele:
						self.zoom = min(self.zoom + step, self.maxZoom)
						
						if self.zoom == self.maxZoom {
							self.zoomDestination = nil
						}
					}
				})
			} else {
				zoomTimer = nil
			}
		}
	}
	
	// MARK: - Focus
	
	let maxFocus = 0x049C
	@Published var focus: Int = Defaults[.focus] {
		didSet {
			Defaults[.focus] = focus
		}
	}
	
	@Published var focusIsAuto: Bool = Defaults[.focusIsAuto] {
		didSet {
			Defaults[.focusIsAuto] = focusIsAuto
		}
	}
	
	enum FocusDestination: Equatable {
		case direct(Int)
		case far
		case near
	}
	
	private var focusTimer: Timer? {
		didSet {
			oldValue?.invalidate()
		}
	}
	
	@Published var focusDestination: FocusDestination? {
		didSet {
			if let focusDestination = focusDestination {
				// from min to max in x seconds
				let step = Int(Double(maxFocus) / 1 * updateInterval)
				
				focusTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true, block: { [weak self] timer in
					guard let self = self else {
						timer.invalidate()
						return
					}
					
					switch focusDestination {
					case let .direct(destination):
						if destination > self.focus {
							self.focus = min(self.focus + step, destination)
						} else {
							self.focus = max(self.focus - step, destination)
						}
						
						if destination == self.focus {
							self.focusDestination = nil
						}
					case .far:
						self.focus = max(self.focus - step, 0)
						
						if self.focus == 0 {
							self.focusDestination = nil
						}
					case .near:
						self.focus = min(self.focus + step, self.maxFocus)
						
						if self.focus == self.maxFocus {
							self.focusDestination = nil
						}
					}
				})
			} else {
				focusTimer = nil
			}
		}
	}
}
