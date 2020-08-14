//
//  PresetColorControl.swift
//  CameraDashboard
//
//  Created by David Beck on 8/13/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import SwiftUI

struct PresetColorControl: View {
	var presetColor: PresetColor
	
    var body: some View {
		Circle()
			.fill(Color(presetColor))
			.frame(width: 20, height: 20)
			.overlay(
				Circle()
					.strokeBorder(Color.gray, lineWidth: 1)
					.blendMode(.multiply)
			)
    }
}

struct PresetColorControl_Previews: PreviewProvider {
    static var previews: some View {
		PresetColorControl(presetColor: .blue).padding()
    }
}
