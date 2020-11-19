import SwiftUI

struct PanTiltSeparators: Shape {
	var outerRingSize: CGFloat
	
	func path(in rect: CGRect) -> Path {
		let radius = min(rect.width, rect.height) / 2
		let innerRadius = radius - outerRingSize
		let center = CGPoint(x: rect.maxX / 2, y: rect.maxY / 2)
		
		var path = Path()
		
		for index in 0..<8 {
			let angle = Angle.degrees(360 * Double(index) / 8) + .degrees(22.5)
			
			path.move(to: CGPoint(
				x: center.x + innerRadius * cos(CGFloat(angle.radians)),
				y: center.y + innerRadius * sin(CGFloat(angle.radians))
			))
			path.addLine(to: CGPoint(
				x: center.x + radius * cos(CGFloat(angle.radians)),
				y: center.y + radius * sin(CGFloat(angle.radians))
			))
		}
		
		path.addEllipse(in: rect.insetBy(dx: outerRingSize, dy: outerRingSize))
		
		return path
	}
}
