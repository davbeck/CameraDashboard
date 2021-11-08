import SwiftUI

struct PresetEditView: View {
	@Config<PresetConfigsKey> var presetConfigs: PresetConfigs
	
	var camera: Camera
	var preset: VISCAPreset
	var client: VISCAClient
	
	@State var isLoading: Bool = false
	@State var error: Swift.Error?
	
	init(camera: Camera, preset: VISCAPreset, client: VISCAClient) {
		self.camera = camera
		self.preset = preset
		self.client = client
		
		_presetConfigs = Config(key: PresetConfigsKey(cameraID: camera.id))
	}
	
	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Text("Name:")
					.column("label", alignment: .trailing)
				TextField("(Optional)", text: $presetConfigs[preset].name)
			}
			HStack {
				Text("Color:")
					.column("label", alignment: .trailing)
				
				PresetColorPicker(presetColor: $presetConfigs[preset].color)
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
