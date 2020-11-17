import SwiftUI

struct PanTiltButton: View {
	@Binding var isPressed: Bool
	
	var body: some View {
		ZStack {
//			PanTiltDirectionShape()
//				.fill(Color.white)
			PanTiltDirectionShape()
				.fill(RadialGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.01960784314, green: 0.4941176471, blue: 1, alpha: 1)), Color(#colorLiteral(red: 0.4235294118, green: 0.7019607843, blue: 0.9803921569, alpha: 1))]), center: .center, startRadius: 70, endRadius: 100))
				.opacity(isPressed ? 1 : 0)
			
			Image("arrowtriangle.up.fill")
				.renderingMode(.template)
				.foregroundColor(isPressed ? Color.white : Color(NSColor.controlTextColor))
				.padding(.bottom, 170)
		}
		.contentShape(PanTiltDirectionShape())
		.gesture(
			DragGesture(minimumDistance: 0)
				.onChanged { value in
					self.isPressed = true
				}
				.onEnded { value in
					self.isPressed = false
				}
		)
	}
}
