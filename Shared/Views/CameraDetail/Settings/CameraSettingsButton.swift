import SwiftUI

struct CameraSettingsButton: View {
	@EnvironmentObject var cameraManager: CameraManager
	
	var camera: Camera
	
	@State var isSettingsOpen: Bool = false
	
	var body: some View {
		Button("Settings") {
			self.isSettingsOpen = true
		}
		.sheet(isPresented: $isSettingsOpen) {
			CameraConnectionSettingsView(camera: camera, isOpen: $isSettingsOpen)
				.environmentObject(cameraManager)
		}
	}
}
