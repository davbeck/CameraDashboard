//
//  PanTiltSeparators.swift
//  CameraDashboard
//
//  Created by David Beck on 8/16/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import SwiftUI

struct PanTiltSeparators: Shape {
	func path(in rect: CGRect) -> Path {
		let radius = min(rect.width, rect.height) / 2
		let innerRadius = radius - 30
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
		
		return path
	}
}
