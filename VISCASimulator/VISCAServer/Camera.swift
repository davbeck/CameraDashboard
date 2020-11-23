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
	struct Destination {
		enum Direction {
			case direct(Int)
			case up
			case down
		}
		
		var direction: Direction
		var speed: Int
	}
	
	class Property: ObservableObject {
		let key: Defaults.Key<Int>
		let minValue: Int
		let maxValue: Int
		
		init(key: Defaults.Key<Int>, minValue: Int, maxValue: Int) {
			self.key = key
			self.minValue = minValue
			self.maxValue = maxValue
			value = Defaults[key]
		}
		
		private var timer: Timer? {
			didSet {
				oldValue?.invalidate()
			}
		}
		
		@Published var value: Int {
			didSet {
				Defaults[key] = value
			}
		}
		
		@Published var destination: Destination? {
			didSet {
				if let destination = destination {
					// zoom from min to max in x seconds
					let step = destination.speed
					
					timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true, block: { [weak self] timer in
						guard let self = self else {
							timer.invalidate()
							return
						}
						
						switch destination.direction {
						case let .direct(destination):
							if destination > self.value {
								self.value = min(self.value + step, destination)
							} else {
								self.value = max(self.value - step, destination)
							}
							
							if destination == self.value {
								self.destination = nil
							}
						case .down:
							self.value = max(self.value - step, self.minValue)
							
							if self.value == self.minValue {
								self.destination = nil
							}
						case .up:
							self.value = min(self.value + step, self.maxValue)
							
							if self.value == self.maxValue {
								self.destination = nil
							}
						}
					})
				} else {
					timer = nil
				}
			}
		}
	}
	
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
	
	let pan = Property(key: .pan, minValue: -0x52EF, maxValue: 0x52EF)
	let tilt = Property(key: .pan, minValue: -0x1BA5, maxValue: 0x52EF)
	
	// MARK: - Zoom
	
	let zoom = Property(key: .zoom, minValue: 0, maxValue: 0x4000)
	
	// MARK: - Focus
	
	let focus = Property(key: .focus, minValue: 0, maxValue: 0x049C)
	
	@Published var focusIsAuto: Bool = Defaults[.focusIsAuto] {
		didSet {
			Defaults[.focusIsAuto] = focusIsAuto
		}
	}
}
