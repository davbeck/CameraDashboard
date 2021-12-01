import Foundation
import CoreData
import SwiftUI

enum PresetColor: Int16, Codable, CaseIterable, Hashable {
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

extension PresetConfig {
	var preset: VISCAPreset {
		get {
			VISCAPreset(rawValue: UInt8(clamping: rawPreset))
		}
		set {
			rawPreset = Int16(newValue.rawValue)
		}
	}
	
	var displayName: String {
		if name.isEmpty {
			return "Preset \(preset.rawValue)"
		} else {
			return name
		}
	}
	
	var color: PresetColor {
		get {
			PresetColor(rawValue: rawColor) ?? .gray
		}
		set {
			rawColor = newValue.rawValue
		}
	}
}
