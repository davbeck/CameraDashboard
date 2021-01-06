import SwiftUI

struct PanTiltButton: View {
	@Binding var isPressed: Bool
	
	var body: some View {
		ToggleButton(isPressed: $isPressed) {
			ZStack {
				PanTiltDirectionShape()
					.fill(Color.selectedContentBackgroundColor)
					.opacity(isPressed ? 1 : 0)
				
				Image(systemSymbol: .arrowtriangleUpFill)
					.renderingMode(.template)
					.foregroundColor(isPressed ? Color.white : Color.controlTextColor)
					.padding(.bottom, 170)
			}
			.contentShape(PanTiltDirectionShape())
		}
	}
}
