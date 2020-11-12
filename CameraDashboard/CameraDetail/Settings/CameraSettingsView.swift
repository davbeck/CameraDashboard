//
//  CameraConnectionSettingsView.swift
//  CameraDashboard
//
//  Created by David Beck on 8/11/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import SwiftUI
import Network

struct CameraConnectionSettingsView: View {
	@EnvironmentObject var cameraManager: CameraManager
	
	@State var camera: Camera
	@Binding var isOpen: Bool
	
	@State var isLoading: Bool = false
	@State var error: Swift.Error?
	
	var isValid: Bool {
		!self.camera.address.isEmpty
	}
	
	var body: some View {
		_CameraConnectionSettingsView(camera: $camera) {
			cameraManager.save(camera: camera) { result in
				isLoading = false
				
				switch result {
				case .success:
					self.isOpen = false
				case .failure(let error):
					self.error = error
				}
			}
		} cancel: {
			self.isOpen = false
		}
		.disabled(isLoading)
		.alert($error)
	}
}

struct _CameraConnectionSettingsView: View {
	@Binding var camera: Camera
	var save: () -> Void
	var cancel: () -> Void
	
	var isValid: Bool {
		!self.camera.address.isEmpty
	}
	
	var body: some View {
		VStack(spacing: 20) {
			Text("Connect to a PTZ camera that supports VISCA over IP")
			VStack {
				HStack(spacing: 5) {
					Text("Name:")
						.column(0, alignment: .trailing)
					TextField("(Optional)", text: $camera.name)
				}
				HStack(spacing: 16) {
					HStack(spacing: 5) {
						Text("Address:")
							.column(0, alignment: .trailing)
						TextField("0.0.0.0", text: $camera.address)
					}
					
					HStack(spacing: 5) {
						Text("Port:")
						TextField(
							"\(NSNumber(value: NWEndpoint.Port.visca.rawValue), formatter: portFormatter)",
							value: $camera.port,
							formatter: portFormatter
						)
						.frame(width: 80)
					}
				}
			}
			
			SaveButtonsView(save: save, cancel: cancel)
		}
		.columnGuide()
		.padding()
	}
}

struct AddCameraView_Previews: PreviewProvider {
	struct CameraConnectionSettingsView: View {
		@State var camera: Camera
		
		var body: some View {
			_CameraConnectionSettingsView(camera: $camera, save: {}, cancel: {})
		}
	}
		
	static var previews: some View {
		Group {
			CameraConnectionSettingsView(camera: Camera(address: ""))
			CameraConnectionSettingsView(camera: Camera(name: "Stage right", address: "192.168.0.102", port: 1234))
		}
	}
}
