import SwiftUI

struct PropertyControl: View {
	var label: String
	@ObservedObject var property: Camera.Property
	
	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			Text("\(label) (\(property.value))")
			Slider(value: $property.value, in: property.minValue ... property.maxValue)
		}
	}
}
