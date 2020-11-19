import Foundation
import Defaults

extension Defaults.Keys {
	static let preset = Key<UInt8>("Camera.preset", default: 0)
	static let zoom = Key<Int>("Camera.zoom", default: 0)
}

let updateInterval: TimeInterval = 0.01

final class Camera: ObservableObject {
	@Published var preset: UInt8 = Defaults[.preset] {
		didSet {
			Defaults[.preset] = preset
		}
	}
	
	@Published var zoom: Int = Defaults[.zoom] {
		didSet {
			Defaults[.zoom] = zoom
		}
	}
	
	enum ZoomDestination: Equatable {
		case direct(Int)
		case max
		case min
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
					case .min:
						break
//						self.zoom -= step
					case .max:
						break
//						self.zoom += step
					}
				})
			} else {
				zoomTimer = nil
			}
		}
	}
}
