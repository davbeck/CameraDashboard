import SwiftUI

struct CameraNavigationRow: View {
	@EnvironmentObject var cameraManager: CameraManager
	@ObservedObject var camera: Camera

	var body: some View {
		HStack {
			Text(camera.displayName)
			Spacer()
			if let client = cameraManager.connections[camera] {
				CameraClientStatusIndicator(client: client)
			}
		}
	}
}

struct CameraClientStatusIndicator: View {
	@ObservedObject var client: VISCAClient

	var body: some View {
		if let error = client.error {
			ConnectionStatusIndicator(error: error)
		}
	}
}
