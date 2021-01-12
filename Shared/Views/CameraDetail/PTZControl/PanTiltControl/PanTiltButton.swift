import SwiftUI

struct PanTiltButton: View {
	@Binding var isPressed: Bool
	var outerRingSize: CGFloat
	var bottomPadding: CGFloat {
		#if os(macOS)
			return 170
		#else
			return 220
		#endif
	}
	
	var body: some View {
		ToggleButton(isPressed: $isPressed) {
			ZStack {
				PanTiltDirectionShape(outerRingSize: outerRingSize)
					.fill(Color.selectedContentBackgroundColor)
					.opacity(isPressed ? 1 : 0)
				
				Image(systemSymbol: .arrowtriangleUpFill)
					.renderingMode(.template)
					.foregroundColor(isPressed ? Color.white : Color.controlTextColor)
					.padding(.bottom, bottomPadding)
			}
			.contentShape(PanTiltDirectionShape(outerRingSize: outerRingSize))
		}
	}
}
