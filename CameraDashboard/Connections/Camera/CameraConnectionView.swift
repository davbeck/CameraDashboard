//
//  CameraConnectionView.swift
//  CameraDashboard
//
//  Created by David Beck on 8/12/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import SwiftUI
import Combine

struct CameraConnectionView: View {
	@EnvironmentObject var cameraManager: CameraManager
	@ObservedObject var client: VISCAClient
	var camera: Camera
	var cameraNumber: Int
	
	@State var isSettingsOpen: Bool = false
	
	var body: some View {
		_CameraConnectionView(
			state: client.state,
			name: camera.name.isEmpty ? "Camera \(cameraNumber)" : camera.name
		) {
			self.isSettingsOpen = true
		}
		.sheet(isPresented: $isSettingsOpen) {
			CameraSettingsView(camera: camera, isOpen: $isSettingsOpen)
				.environmentObject(cameraManager)
		}
	}
}

struct _CameraConnectionView: View {
	var state: VISCAClient.State
	var name: String
	
	var openSettings: (() -> Void)? = nil
	
	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				ConnectionStatusIndicator(state: state)
				Text(name)
			}
			
			Button("Settings") {
				openSettings?()
			}
		}
	}
}

struct CameraConnectionView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			_CameraConnectionView(
				state: .ready,
				name: "Stage right"
			)
		}
	}
}
