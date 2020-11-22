import SwiftUI

struct ContentView: View {
	@EnvironmentObject var camera: Camera
	
	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Text("Preset: \(camera.preset)")
			
			VStack(alignment: .leading, spacing: 0) {
				Text("Zoom (\(camera.zoom))")
				Slider(value: $camera.zoom, in: 0...Int(UInt16.max))
			}
			
			VStack(alignment: .leading, spacing: 0) {
				HStack {
					Text("Focus (\(camera.focus))")
					Spacer()
					Toggle(isOn: $camera.focusIsAuto) {
						Text("Auto")
					}
				}
				Slider(value: $camera.focus, in: 0...Int(UInt16.max))
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
