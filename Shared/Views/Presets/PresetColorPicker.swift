import SwiftUI

struct PresetColorPicker: View {
	@Binding var presetColor: PresetColor
	
	var body: some View {
		HStack {
			ForEach(PresetColor.allCases, id: \.self) { presetColor in
				PresetColorControl(
					presetColor: presetColor,
					isSelected: self.presetColor == presetColor
				)
					.onTapGesture {
						self.presetColor = presetColor
					}
			}
		}
	}
}

struct PresetColorPicker_Previews: PreviewProvider {
	static var previews: some View {
		PresetColorPicker(presetColor: .constant(.blue))
	}
}
