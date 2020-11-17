import SwiftUI

struct AddCameraButton: View {
	@State var isAddingCamera: Bool = false
	@ObservedObject var cameraManager = CameraManager.shared
	
	var body: some View {
		Button(action: {
			isAddingCamera.toggle()
		}, label: {
			Image(systemSymbol: .plus)
		})
			.sheet(isPresented: $isAddingCamera) {
				CameraConnectionSettingsView(camera: Camera(address: ""), isOpen: $isAddingCamera)
					.environmentObject(cameraManager)
			}
	}
}

struct AddCameraButton_Previews: PreviewProvider {
	static var previews: some View {
		AddCameraButton()
	}
}
