import SwiftUI

struct PresetEditView: View {
	@EnvironmentObject var cameraManager: CameraManager
	
	var camera: Camera
	var preset: VISCAPreset
	var client: VISCAClient
	
	@State var isLoading: Bool = false
	@State var error: Swift.Error?
	
	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Text("Name:")
					.column("label", alignment: .trailing)
				TextField("(Optional)", text: $cameraManager[camera, preset].name)
			}
			HStack {
				Text("Color:")
					.column("label", alignment: .trailing)
				
				PresetColorPicker(presetColor: $cameraManager[camera, preset].color)
			}
			
			HStack {
				Spacer()
				Button {
					client.set(preset)
				} label: {
					Text("Set to Current Position")
				}
			}
		}
		.foregroundColor(Color.primary)
		.columnGuide()
		.padding()
		.disabled(isLoading)
		.alert($error)
	}
}

// struct PresetEditView_Previews: PreviewProvider {
//	static var previews: some View {
//		_PresetEditView(presetConfig: .constant(PresetConfig()))
//	}
// }
