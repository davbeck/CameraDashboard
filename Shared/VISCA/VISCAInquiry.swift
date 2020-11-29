import Foundation

struct VISCAInquiry<Response> {
	var name: String
	var payload: Data
	var parseResponse: (_ payload: Data) -> Response?
}

extension VISCAInquiry where Response == VISCAVersion {
	static let version = Self(name: "version", payload: [0x09, 0x00, 0x02]) { payload in
		guard payload.count == 8 else { return nil }
		
		let venderID = payload.dropFirst(1).load(as: UInt16.self)
		let modelID = payload.dropFirst(3).load(as: UInt16.self)
		let armVersion = payload.dropFirst(5).load(as: UInt16.self)
		let reserve = payload.dropFirst(7).load(as: UInt8.self)
		
		return VISCAVersion(
			venderID: venderID,
			modelID: modelID,
			armVersion: armVersion,
			reserve: reserve
		)
	}
}

extension VISCAInquiry where Response == VISCAPreset {
	static let preset = Self(name: "preset", payload: [0x09, 0x04, 0x3F]) { payload in
		guard
			payload.count == 2, payload.first == 0x50,
			let value = payload.dropFirst(1).first
		else { return nil }
		return VISCAPreset(rawValue: value)
	}
}

extension VISCAInquiry where Response == UInt16 {
	static let zoomPosition = Self(name: "zoomPosition", payload: [0x09, 0x04, 0x47]) { payload in
		guard payload.first == 0x50 else { return nil }
		let value = payload.dropFirst(1).loadBitPadded(as: UInt16.self)
		print("zoomPosition", value)
		return value
	}
}

extension VISCAInquiry where Response == UInt16 {
	static let focusPosition = Self(name: "focusPosition", payload: [0x09, 0x04, 0x48]) { payload in
		guard payload.first == 0x50 else { return nil }
		return payload.dropFirst(1).loadBitPadded(as: UInt16.self)
	}
}

extension VISCAInquiry where Response == VISCAFocusMode {
	static let focusMode = Self(name: "focusMode", payload: [0x09, 0x04, 0x38]) { payload in
		guard payload.first == 0x50 else { return nil }
		switch payload.dropFirst(1).first {
		case 0x02:
			return .auto
		case 0x03:
			return .manual
		default:
			return nil
		}
	}
}
