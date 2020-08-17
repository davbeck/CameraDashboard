//
//  PanTiltButtonStyle.swift
//  CameraDashboard
//
//  Created by David Beck on 8/16/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import SwiftUI

struct PanTiltButtonStyle: ButtonStyle {
	func makeBody(configuration: Self.Configuration) -> some View {
		ZStack {
			PanTiltDirectionShape()
				.fill(Color.white)
			PanTiltDirectionShape()
				.fill(RadialGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.01960784314, green: 0.4941176471, blue: 1, alpha: 1)), Color(#colorLiteral(red: 0.4235294118, green: 0.7019607843, blue: 0.9803921569, alpha: 1))]), center: .center, startRadius: 70, endRadius: 100))
				.opacity(configuration.isPressed ? 1 : 0)
			
			configuration.label
				.foregroundColor(configuration.isPressed ? Color.white : Color(NSColor.controlTextColor))
				.padding(.bottom, 170)
		}
	}
}
