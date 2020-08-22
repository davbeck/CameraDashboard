//
//  CameraContentView.swift
//  CameraDashboard
//
//  Created by David Beck on 8/15/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import SwiftUI

struct CameraContentView: View {
	var connection: CameraConnection
	var cameraNumber: Int
	
	var body: some View {
		TabView(content: {
			CameraPTZControlTab(client: connection.client, camera: connection.camera)
		})
			.padding()
			.frame(
				minWidth: 400,
				maxWidth: .infinity,
				minHeight: 300,
				maxHeight: .infinity
			)
	}
}

struct CameraContentView_Previews: PreviewProvider {
	static var previews: some View {
		CameraContentView(
			connection: CameraConnection(),
			cameraNumber: 2
		)
	}
}
