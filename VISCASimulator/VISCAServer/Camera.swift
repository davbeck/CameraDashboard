import Foundation
import Defaults

extension Defaults.Keys {
	static let preset = Key<UInt8>("Camera.preset", default: 0)
	static let zoom = Key<Int>("Camera.zoom", default: 0)
	static let focus = Key<Int>("Camera.focus", default: 0)
	static let focusIsAuto = Key<Bool>("Camera.focusIsAuto", default: true)
}

let updateInterval: TimeInterval = 0.01

final class Camera: ObservableObject {
	@Published var preset: UInt8 = Defaults[.preset] {
		didSet {
			Defaults[.preset] = preset
		}
	}
	
	// MARK: - Zoom
	
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
				let step = Int(Double(UInt16.max) / 5 * updateInterval)
				
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
						self.zoom = min(self.zoom + step, Int(UInt16.max))
						
						if self.zoom == Int(UInt16.max) {
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
				let step = Int(Double(UInt16.max) / 1 * updateInterval)
				
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
						self.focus = min(self.focus + step, Int(UInt16.max))
						
						if self.focus == Int(UInt16.max) {
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
