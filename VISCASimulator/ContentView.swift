import SwiftUI

struct ContentView: View {
	@EnvironmentObject var camera: Camera
	
	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Picker(selection: $camera.preset, label: Text("Preset")) {
				ForEach(0...UInt8(255), id: \.self) { preset in
					Text("\(preset)")
						.foregroundColor(camera.presets.keys.contains(preset) ? Color.primary : Color.gray)
						.font(Font.body.monospacedDigit())
				}
			}
			
			VStack(alignment: .leading, spacing: 0) {
				Text("Pan (\(camera.pan))")
				Slider(value: $camera.pan, in: camera.minPan...camera.maxPan)
			}
			
			VStack(alignment: .leading, spacing: 0) {
				Text("Tilt (\(camera.tilt))")
				Slider(value: $camera.tilt, in: camera.minTilt...camera.maxTilt)
			}
			
			VStack(alignment: .leading, spacing: 0) {
				Text("Zoom (\(camera.zoom))")
				Slider(value: $camera.zoom, in: 0...camera.maxZoom)
			}
			
			VStack(alignment: .leading, spacing: 0) {
				HStack {
					Text("Focus (\(camera.focus))")
					Spacer()
					Toggle(isOn: $camera.focusIsAuto) {
						Text("Auto")
					}
				}
				Slider(value: $camera.focus, in: 0...camera.maxFocus)
			}
		}
		.font(Font.body.monospacedDigit())
		.padding()
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
