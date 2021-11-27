import SwiftUI

struct ActionPresetOption: View {
	@ObservedObject var presetConfig: PresetConfig
	
	var body: some View {
		Text(presetConfig.displayName)
			.tag(presetConfig as PresetConfig?)
	}
}

struct ActionPresetControl: View {
	@ObservedObject var camera: Camera
	@Binding var selection: PresetConfig?
	
	var body: some View {
		Picker(selection: $selection, label: Text("Preset")) {
			ForEach(VISCAPreset.allCases) { preset in
				Group {
					ActionPresetOption(presetConfig: camera[preset])
				}
			}
			.font(.body.monospacedDigit())
		}
	}
}

// struct ActionPresetControl_Previews: PreviewProvider {
//	static var previews: some View {
//		ActionPresetControl(selection: .constant(VISCAPreset(rawValue: 3)))
//	}
// }
