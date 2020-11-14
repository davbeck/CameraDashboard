//
//  PanTiltThumb.swift
//  CameraDashboard
//
//  Created by David Beck on 8/16/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import SwiftUI

struct PanTiltThumb: View {
	@Environment(\.displayScale) var displayScale
	
	var size: CGFloat
	
	var body: some View {
		ZStack {
			Circle()
				.fill(LinearGradient(
					gradient: Gradient(colors: [Color(#colorLiteral(red: 0.2980392157, green: 0.6352941176, blue: 0.9764705882, alpha: 1)), Color(#colorLiteral(red: 0, green: 0.3607843137, blue: 1, alpha: 1))]),
					startPoint: .top,
					endPoint: .bottom
				))
				.frame(width: size + 2, height: size + 2)
				.shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1 / displayScale)
			Circle()
				.fill(LinearGradient(
					gradient: Gradient(colors: [Color(#colorLiteral(red: 0.4235294118, green: 0.7019607843, blue: 0.9803921569, alpha: 1)), Color(#colorLiteral(red: 0.01960784314, green: 0.4941176471, blue: 1, alpha: 1))]),
					startPoint: .top,
					endPoint: .bottom
				))
				.frame(width: size, height: size)
		}
	}
}
