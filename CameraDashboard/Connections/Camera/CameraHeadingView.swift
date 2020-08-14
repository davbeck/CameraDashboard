//
//  CameraHeadingView.swift
//  CameraDashboard
//
//  Created by David Beck on 8/12/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import SwiftUI

struct CameraHeadingView: View {
	@EnvironmentObject var cameraManager: CameraManager
	
	var body: some View {
		ZStack {
			VStack(alignment: .leading, spacing: 15) {
				ForEach(Array(cameraManager.connections.enumerated()), id: \.1.id) { row, connection in
					CameraConnectionView(
						client: connection.client,
						camera: connection.camera,
						cameraNumber: row + 1
					)
					.frame(height: 100)
				}
			}
			.padding()
			.fixedSize(horizontal: true, vertical: true)
			.background(Color(NSColor.windowBackgroundColor).opacity(0.8))
		}
	}
}

struct CameraHeadingView_Previews: PreviewProvider {
	static var previews: some View {
		CameraHeadingView()
	}
}
