import SwiftUI

struct FocusControl: View {
	@ObservedObject var camera: Camera
	@ObservedObject var property: Camera.Property
	
	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			HStack {
				Text("Focus (\(property.value))")
				Spacer()
				Toggle(isOn: $camera.focusIsAuto) {
					Text("Auto")
				}
			}
			Slider(value: $property.value, in: property.minValue...property.maxValue)
		}
	}
}
