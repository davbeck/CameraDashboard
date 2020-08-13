//
//  VISCAPreset.swift
//  CameraDashboard
//
//  Created by David Beck on 8/13/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import Foundation

struct VISCAPreset: Hashable, RawRepresentable {
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
