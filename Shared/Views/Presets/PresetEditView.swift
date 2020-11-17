import SwiftUI

struct PresetEditView: View {
	@EnvironmentObject var cameraManager: CameraManager
	
	@Binding var presetConfig: PresetConfig
	
	@Binding var isOpen: Bool
	
	@State var isLoading: Bool = false
	@State var error: Swift.Error?
	
	var body: some View {
		_PresetEditView(presetConfig: $presetConfig)
			.disabled(isLoading)
			.alert($error)
	}
}

struct _PresetEditView: View {
	@Binding var presetConfig: PresetConfig
	
	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Text("Name:")
					.column("label", alignment: .trailing)
				TextField("(Optional)", text: $presetConfig.name)
			}
			HStack {
				Text("Color:")
					.column("label", alignment: .trailing)
				
				PresetColorPicker(presetColor: $presetConfig.color)
			}
		}
		.columnGuide()
		.padding()
	}
}

struct PresetEditView_Previews: PreviewProvider {
	static var previews: some View {
		_PresetEditView(presetConfig: .constant(PresetConfig()))
	}
}
