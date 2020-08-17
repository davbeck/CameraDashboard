//
//  PanTiltControl.swift
//  CameraDashboard
//
//  Created by David Beck on 8/15/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import SwiftUI

struct PanTiltControl: View {
	@Environment(\.displayScale) var displayScale
	
	@Binding var direction: PTZDirection?
	@Binding var speed: Double?
	
	@State var location: CGPoint? = nil
	
	func angle(at location: CGPoint) -> Angle {
		return Angle.radians(Double(atan2(
			location.y - 100,
			location.x - 100
		)))
	}
	
	func distance(at location: CGPoint) -> CGFloat {
		return min(
			sqrt(pow(location.x - 100, 2) + pow(location.y - 100, 2)),
			57.5
		)
	}
	
	func normalizedThumbLocation(at location: CGPoint) -> CGPoint {
		let angle = self.angle(at: location)
		let distance = self.distance(at: location)
		return CGPoint(
			x: distance * CGFloat(cos(angle.radians)) + 100,
			y: distance * CGFloat(sin(angle.radians)) + 100
		)
	}
	
//	func direction(at location: CGPoint) -> PTZDirection {
//
//	}
	
	var body: some View {
		ZStack {
			Circle()
				.fill(Color(NSColor.controlBackgroundColor))
				.frame(width: 200, height: 200)
				.shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1 / displayScale)
				
			ForEach(Array(PTZDirection.allCases.enumerated()), id: \.1) { index, direction in
				Button(action: {}, label: {
					Image("arrowtriangle.up.fill")
						.renderingMode(.template)
				})
					.buttonStyle(PanTiltButtonStyle())
					.rotationEffect(.degrees(360 / 8) * Double(index))
			}
				
			PanTiltSeparators()
				.stroke(Color(#colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1)), lineWidth: 1 / displayScale)
				.frame(width: 200, height: 200)
				
			Circle()
				.stroke(Color(#colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1)), lineWidth: 1 / displayScale)
				.frame(width: 140, height: 140)
				
			Circle()
				.stroke(Color(NSColor.controlTextColor).opacity(0.15), lineWidth: 1 / displayScale)
				.opacity(0.5)
				
			if let location = location {
				PanTiltThumb()
					.position(self.normalizedThumbLocation(at: location))
			}
		}
		.frame(width: 200, height: 200, alignment: .center)
		.gesture(
			DragGesture(minimumDistance: 0)
				.onChanged { value in
					self.location = value.location
				}
				.onEnded { value in
					self.location = nil
					
					self.direction = nil
					self.speed = nil
				}
		)
	}
}

struct PanTiltControl_Previews: PreviewProvider {
	static var previews: some View {
		PanTiltControl(direction: .constant(nil), speed: .constant(nil))
			.padding()
			.background(Color(NSColor.windowBackgroundColor))
	}
}
