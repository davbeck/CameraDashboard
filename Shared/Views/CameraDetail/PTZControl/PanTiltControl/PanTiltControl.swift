import SwiftUI

struct PanTiltControl: View {
	@Environment(\.displayScale) var displayScale

	@Binding var vector: PTZVector?

	var size: CGFloat

	var outerRingSize: CGFloat {
		#if os(macOS)
			return 30
		#else
			return 44
		#endif
	}

	var innerSize: CGFloat {
		size - outerRingSize * 2
	}

	var body: some View {
		ZStack {
			Circle()
				.fill(Color.controlColor)
				.frame(width: size, height: size)
				.shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1 / displayScale)

			ForEach(Array(PTZDirection.allCases.enumerated()), id: \.1) { index, direction in
				PanTiltButton(isPressed: Binding(get: {
					self.vector == .direction(direction)
				}, set: { newValue in
					if newValue {
						self.vector = .direction(direction)
					} else {
						self.vector = nil
					}
				}), outerRingSize: outerRingSize)
					.rotationEffect(.degrees(360 / 8) * Double(index))
			}

			PanTiltSeparators(outerRingSize: outerRingSize)
				.stroke(Color(#colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1)), lineWidth: 1 / displayScale)
				.frame(width: size, height: size)

			Circle()
				.stroke(Color.controlTextColor.opacity(0.15), lineWidth: 1 / displayScale)
				.opacity(0.5)

			PanTiltRelativeControl(vector: $vector, size: innerSize)
		}
		.acceptsFirstMouse()
		.frame(width: size, height: size, alignment: .center)
	}
}

struct PanTiltControl_Previews: PreviewProvider {
	static var previews: some View {
		PanTiltControl(vector: .constant(nil), size: 200)
			.padding()
			.background(Color.gray)
	}
}
