//
//  CameraPTZControlTab.swift
//  CameraDashboard
//
//  Created by David Beck on 8/15/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import SwiftUI

struct CameraPTZControlTab: View {
	var connection: CameraConnection
	
	@State var direction: PTZDirection? = nil
	@State var speed: Double? = nil
	
	var body: some View {
		HStack {
			Spacer()
			PanTiltControl(direction: $direction, speed: $speed)
		}
			.padding()
			.tabItem {
				Text("Controls")
			}
	}
}

struct CameraPTZControlTab_Previews: PreviewProvider {
	static var previews: some View {
		CameraPTZControlTab(connection: CameraConnection())
	}
}
