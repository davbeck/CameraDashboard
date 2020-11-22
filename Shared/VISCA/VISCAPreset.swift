import Foundation

struct VISCAPreset: Codable, Hashable, RawRepresentable {
	var rawValue: UInt8
	
	init?(rawValue: UInt8) {
		guard rawValue < 255 else { return nil }
		self.rawValue = rawValue
	}
}

extension VISCAPreset: CaseIterable {
	static var allCases: [Self] {
		(0..<255).map { Self(rawValue: $0)! }
	}
}

extension VISCAPreset: Identifiable {
	var id: UInt8 {
		return rawValue
	}
}
