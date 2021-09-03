import SwiftUI

struct ActionPresetOption: View {
	@Config<PresetConfigKey> var presetConfig: PresetConfig
	var preset: VISCAPreset
	
	init(cameraID: UUID, preset: VISCAPreset) {
		self.preset = preset
		_presetConfig = Config(key: PresetConfigKey(
			cameraID: cameraID,
			preset: preset
		))
	}
	
	var body: some View {
		if presetConfig.name.isEmpty {
			Text("Preset \(preset.rawValue)")
		} else {
			Text(presetConfig.name)
		}
	}
}

struct ActionPresetControl: View {
	var cameraID: UUID?
	@Binding var selection: VISCAPreset
	
	var body: some View {
		Picker(selection: $selection, label: Text("Preset")) {
			ForEach(VISCAPreset.allCases) { preset in
				Group {
					if let cameraID = cameraID {
						ActionPresetOption(cameraID: cameraID, preset: preset)
					} else {
						Text("Preset \(preset.rawValue)")
					}
				}
				.font(.body.monospacedDigit())
				.tag(preset)
			}
		}
	}
}

struct ActionPresetControl_Previews: PreviewProvider {
	static var previews: some View {
		ActionPresetControl(selection: .constant(VISCAPreset(rawValue: 3)))
	}
}
