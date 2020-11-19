import SwiftUI

struct ContentView: View {
	@EnvironmentObject var camera: Camera
	
	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Text("Preset: \(camera.preset)")
			
			HStack {
				Text("Zoom")
				Slider(value: $camera.zoom, in: 0...Int(UInt16.max))
				Text("\(camera.zoom)")
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
