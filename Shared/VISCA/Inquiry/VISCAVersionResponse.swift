import Foundation

extension VISCAInquiry where Response == VISCAVersion {
	static let version = Self(payload: [0x09, 0x00, 0x02]) { payload in
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
