//
//  AddCameraView.swift
//  CameraDashboard
//
//  Created by David Beck on 8/11/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import SwiftUI

struct AddCameraView: View {
	@EnvironmentObject var cameraManager: CameraManager
	
	@Binding var isOpen: Bool
	@State var isLoading: Bool = false
	@State var error: Swift.Error?
	
	var body: some View {
		CameraSettingsView(isLoading: isLoading, save: { camera in
			isLoading = true
			
			cameraManager.add(camera: camera) { result in
				isLoading = false
				
				switch result {
				case .success:
					self.isOpen = false
				case .failure(let error):
					self.error = error
				}
			}
		}, cancel: {
			self.isOpen = false
		})
			.alert(isPresented: Binding(get: {
				self.error != nil
				}, set: { newValue in
					if !newValue {
						self.error = nil
					}
				}), content: {
				Alert(
					title: Text("Failed to add camera"),
					message: error.map { Text($0.localizedDescription) },
					dismissButton: Alert.Button.cancel(Text("OK"))
				)
				})
	}
}
