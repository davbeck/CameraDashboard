import SwiftUI

struct PanTiltRelativeControl: View {
	@Binding var vector: PTZVector?
	var size: CGFloat
	
	var radius: CGFloat {
		size / 2
	}
	
	var thumbSize: CGFloat {
		#if os(macOS)
			return 25
		#else
			return 44
		#endif
	}
	
	var maxDistance: CGFloat {
		radius - thumbSize / 2
	}
	
	var body: some View {
		ZStack {
			if let vector = self.vector, case let PTZVector.relative(angle: angle, speed: speed) = vector {
				PanTiltThumb(size: thumbSize)
					.position(CGPoint(
						x: CGFloat(speed * Double(maxDistance) * cos(angle.radians)) + radius,
						y: CGFloat(speed * Double(maxDistance) * sin(angle.radians)) + radius
					))
			}
		}
		.frame(width: size, height: size)
		.contentShape(Circle())
		.gesture(
			DragGesture(minimumDistance: 0)
				.onChanged { value in
					self.vector = .relative(
						angle: Angle.radians(Double(atan2(
							value.location.y - radius,
							value.location.x - radius
						))),
						speed: Double(min(
							sqrt(pow(value.location.x - radius, 2) + pow(value.location.y - radius, 2)),
							maxDistance
						) / maxDistance)
					)
				}
				.onEnded { value in
					self.vector = nil
				}
		)
	}
}
