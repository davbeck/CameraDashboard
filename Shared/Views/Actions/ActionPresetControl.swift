import SwiftUI

struct ActionPresetOptions: View {
	@Config<PresetConfigsKey> var presetConfigs: PresetConfigs
	
	var cameraID: UUID
	
	init(cameraID: UUID) {
		self.cameraID = cameraID
		_presetConfigs = Config(key: PresetConfigsKey(
			cameraID: cameraID
		))
	}
	
	var body: some View {
		ForEach(VISCAPreset.allCases) { preset in
			Group {
				if presetConfigs[preset].name.isEmpty {
					Text("Preset \(preset.rawValue)")
				} else {
					Text(presetConfigs[preset].name)
				}
			}
		}
	}
}

struct ActionPresetControl: View {
	var cameraID: UUID?
	@Binding var selection: VISCAPreset
	
	var body: some View {
		Picker(selection: $selection, label: Text("Preset")) {
			Group {
				if let cameraID = cameraID {
					ActionPresetOptions(cameraID: cameraID)
				} else {
					ForEach(VISCAPreset.allCases) { preset in
						Text("Preset \(preset.rawValue)")
					}
				}
			}
			.font(.body.monospacedDigit())
		}
	}
}

struct ActionPresetControl_Previews: PreviewProvider {
	static var previews: some View {
		ActionPresetControl(selection: .constant(VISCAPreset(rawValue: 3)))
	}
}
