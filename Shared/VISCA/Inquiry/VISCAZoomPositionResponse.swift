import Foundation

extension VISCAInquiry where Response == UInt16 {
	static let zoomPosition = Self(payload: [0x09, 0x04, 0x47]) { payload in
		guard payload.first == 0x50 else { return nil }
		return payload.dropFirst(1).loadBitPadded(as: UInt16.self)
	}
}
