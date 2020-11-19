import SwiftUI

struct PanTiltDirectionShape: Shape {
	func path(in rect: CGRect) -> Path {
		Path { path in
			let radius = min(rect.width, rect.height) / 2
			let innerRadius = radius - 30
			let center = CGPoint(x: radius, y: radius)
			
			let startAngle = Angle.degrees(-360 / 16 - 90)
			let endAngle = Angle.degrees(360 / 16 - 90)
			
			path.move(to: CGPoint(
				x: center.x + innerRadius * cos(CGFloat(startAngle.radians)),
				y: center.y + innerRadius * sin(CGFloat(startAngle.radians))
			))
			path.addArc(
				center: center,
				radius: radius,
				startAngle: startAngle,
				endAngle: endAngle,
				clockwise: false
			)
			path.addLine(to: CGPoint(
				x: center.x + innerRadius * cos(CGFloat(endAngle.radians)),
				y: center.y + innerRadius * sin(CGFloat(endAngle.radians))
			))
			path.addArc(
				center: center,
				radius: innerRadius,
				startAngle: endAngle,
				endAngle: startAngle,
				clockwise: true
			)
		}
	}
}
