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
	@State var isAddingCamera: Bool = false
	
	var body: some View {
		ZStack {
			// sheet doesn't work when a child view also has a sheet
			Spacer()
				.sheet(isPresented: $isAddingCamera) {
					CameraSettingsView(camera: Camera(address: ""), isOpen: $isAddingCamera)
						.environmentObject(cameraManager)
				}
			
			VStack(alignment: .leading, spacing: 15) {
				ForEach(Array(cameraManager.connections.enumerated()), id: \.1.id) { row, connection in
					CameraConnectionView(
						client: connection.client,
						camera: connection.camera,
						cameraNumber: row + 1
					)
					.frame(height: 100)
				}
				
				Button(action: {
					isAddingCamera.toggle()
				}, label: {
					Text("Add Camera")
				})
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
