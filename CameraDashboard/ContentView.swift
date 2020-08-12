//
//  ContentView.swift
//  Canera Switcher
//
//  Created by David Beck on 8/4/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import SwiftUI

struct ContentView: View {
	@ObservedObject var cameraManager = CameraManager.shared
	@State var isAddingCamera: Bool = false
	
	var body: some View {
		Button(action: {
			isAddingCamera.toggle()
		}, label: {
			Text("Add Camera")
		})
			.padding()
			.sheet(isPresented: $isAddingCamera) {
				AddCameraView(isOpen: $isAddingCamera)
					.environmentObject(cameraManager)
			}
			.environmentObject(cameraManager)
	}
}
