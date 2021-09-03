import Foundation

struct VISCAPreset: Codable, Hashable, RawRepresentable {
	var rawValue: UInt8
	
	init(rawValue: UInt8) {
		self.rawValue = rawValue
	}
}

extension VISCAPreset: CaseIterable {
	static var allCases: [Self] {
		(UInt8.min...UInt8.max).map { Self(rawValue: $0) }
	}
}

extension VISCAPreset: Identifiable {
	var id: UInt8 {
		return rawValue
	}
}
