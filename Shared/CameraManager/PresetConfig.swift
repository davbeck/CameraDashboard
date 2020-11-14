//
//  PresetConfig.swift
//  CameraDashboard
//
//  Created by David Beck on 8/13/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import Foundation
import SwiftUI

enum PresetColor: String, Codable, CaseIterable, Hashable {
	case gray
	case red
	case orange
	case yellow
	case green
	case teale
	case blue
	case purple
}

extension Color {
	init(_ presetColor: PresetColor) {
		switch presetColor {
		case .gray:
			self = Color.gray
		case .red:
			self = Color.red
		case .orange:
			self = Color.orange
		case .yellow:
			self = Color.yellow
		case .green:
			self = Color.green
		case .teale:
			self.init(#colorLiteral(red: 0.007843137255, green: 0.7803921569, blue: 0.8156862745, alpha: 1))
		case .blue:
			self = Color.blue
		case .purple:
			self = Color.purple
		}
	}
}

struct PresetKey: Codable, Hashable {
	var cameraID: UUID
	var preset: VISCAPreset
}

struct PresetConfig: Codable, Hashable {
	var name: String = ""
	var color: PresetColor = .gray
}
