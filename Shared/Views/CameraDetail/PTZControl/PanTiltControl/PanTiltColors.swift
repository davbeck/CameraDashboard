import SwiftUI

extension Color {
	static var selectedContentBackgroundColor: Color {
		#if os(macOS)
			return Color(NSColor.selectedContentBackgroundColor)
		#else
			return Color.blue
		#endif
	}
	
	static var controlTextColor: Color {
		#if os(macOS)
			return Color(NSColor.controlTextColor)
		#else
			return Color.blue
		#endif
	}
	
	static var controlColor: Color {
		#if os(macOS)
			return Color(NSColor.controlColor)
		#else
			return Color.white
		#endif
	}
}
