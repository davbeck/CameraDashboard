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
	@ObservedObject var errorReporter = ErrorReporter.shared
	@State var isAddingCamera: Bool = false
	
	var body: some View {
		VStack(spacing: 0) {
			HStack(alignment: .top) {
				CameraHeadingView()
				
				PresetsView()
			}
			
			HStack {
				Button(action: {
					isAddingCamera.toggle()
				}, label: {
					Text("Add Camera")
				})
					.sheet(isPresented: $isAddingCamera) {
						CameraSettingsView(camera: Camera(address: ""), isOpen: $isAddingCamera)
							.environmentObject(cameraManager)
					}
				
				Spacer()
				
				if let error = errorReporter.lastError {
					Text(error.localizedDescription)
						.lineLimit(1)
						.truncationMode(.middle)
						.foregroundColor(Color.red)
						.transition(.opacity)
				}
			}
			.padding()
		}
		.frame(minWidth: 600, minHeight: 300)
		.fixedSize(horizontal: false, vertical: true)
		.environmentObject(cameraManager)
		.environmentObject(errorReporter)
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
