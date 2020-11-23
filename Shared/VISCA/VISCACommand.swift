import Foundation

struct VISCACommand: Equatable {
	/// The command classification
	///
	/// Commands with the same classification cancel each other out. For instance, zoom tele cancels zoom wide. These are safe to issue concurrently because you will get completion for the previous command before confirmation of the next.
	struct Group: OptionSet {
		let rawValue: UInt
		
		static let panTilt = Group(rawValue: 1 << 0)
		static let zoom = Group(rawValue: 1 << 1)
		static let focus = Group(rawValue: 1 << 2)
		static let preset: Group = [.panTilt, .zoom]
	}
	
	var group: Group?
	
	var payload: Data
	
	// MARK: Zoom
	
	static let zoomTele = VISCACommand(group: .zoom, payload: Data([0x01, 0x04, 0x07, 0x02]))
	static let zoomWide = VISCACommand(group: .zoom, payload: Data([0x01, 0x04, 0x07, 0x03]))
	static let zoomStop = VISCACommand(group: .zoom, payload: Data([0x01, 0x04, 0x07, 0x00]))
	static func zoomDirect(_ position: UInt16) -> VISCACommand {
		VISCACommand(group: .zoom, payload: Data([0x01, 0x04, 0x47]) + position.bitPadded)
	}
	
	// MARK: Focus
	
	static let focusTele = VISCACommand(group: .focus, payload: Data([0x01, 0x04, 0x08, 0x02]))
	static let focusWide = VISCACommand(group: .focus, payload: Data([0x01, 0x04, 0x08, 0x03]))
	static let focusStop = VISCACommand(group: .focus, payload: Data([0x01, 0x04, 0x08, 0x00]))
	static func focusDirect(_ position: UInt16) -> VISCACommand {
		VISCACommand(group: .focus, payload: Data([0x01, 0x04, 0x48]) + position.bitPadded)
	}
	
	static let setAutoFocus = VISCACommand(group: nil, payload: Data([0x01, 0x04, 0x38, 0x02]))
	static let setManualFocus = VISCACommand(group: nil, payload: Data([0x01, 0x04, 0x38, 0x03]))
	
	// Presets
	
	static func set(_ preset: VISCAPreset) -> VISCACommand {
		VISCACommand(group: .preset, payload: [0x01, 0x04, 0x3F, 0x01, preset.rawValue])
	}
	
	static func recall(_ preset: VISCAPreset) -> VISCACommand {
		VISCACommand(group: .preset, payload: Data([0x01, 0x04, 0x3F, 0x02, preset.rawValue]))
	}
	
	// Pan Tilt
	
	static func panTilt(direction: PTZDirection, panSpeed: UInt8, tiltSpeed: UInt8) -> VISCACommand {
		var payload = Data([0x01, 0x06, 0x01])
		payload.append(min(max(panSpeed, 0x01), 0x18))
		payload.append(min(max(tiltSpeed, 0x01), 0x14))
		
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
		
		return VISCACommand(group: .panTilt, payload: payload)
	}
	
	static let panTiltStop = VISCACommand(group: .panTilt, payload: Data([
		0x01, 0x06, 0x01,
		0x18, 0x18, // speed placeholder
		0x03, 0x03,
	]))
}
