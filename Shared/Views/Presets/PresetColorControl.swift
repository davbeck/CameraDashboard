import SwiftUI

struct PresetColorControl: View {
	var presetColor: PresetColor
	var isSelected: Bool
	
	var body: some View {
		Circle()
			.fill(Color(presetColor))
			.frame(width: 25, height: 25)
			.overlay(
				Image("checkmark")
					.foregroundColor(.white)
					.opacity(isSelected ? 1 : 0)
			)
			.overlay(
				Circle()
					.strokeBorder(Color.gray, lineWidth: 1)
					.blendMode(.multiply)
			)
	}
}

struct PresetColorControl_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			PresetColorControl(presetColor: .blue, isSelected: false).padding()
			PresetColorControl(presetColor: .red, isSelected: true).padding()
		}
	}
}
