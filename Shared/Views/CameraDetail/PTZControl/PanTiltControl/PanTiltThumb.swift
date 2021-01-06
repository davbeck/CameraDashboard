import SwiftUI

struct PanTiltThumb: View {
	@Environment(\.displayScale) var displayScale
	
	var size: CGFloat
	
	var body: some View {
		Circle()
			.fill(Color.selectedContentBackgroundColor)
			.frame(width: size, height: size)
			.shadow(color: Color.black.opacity(0.15), radius: 0.5, x: 0.0, y: 0.5)
	}
}
