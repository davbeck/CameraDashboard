import SwiftUI

struct ContentView: View {
	@EnvironmentObject var camera: Camera
	@EnvironmentObject var server: VISCAServer
	
	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Picker(selection: $camera.preset, label: Text("Preset")) {
				ForEach(0...UInt8(255), id: \.self) { preset in
					Text("\(preset)")
						.foregroundColor(camera.presets.keys.contains(preset) ? Color.primary : Color.gray)
						.font(Font.body.monospacedDigit())
				}
			}
			
			PropertyControl(label: "Pan", property: camera.pan)
			PropertyControl(label: "Tilt", property: camera.tilt)
			
			PropertyControl(label: "Zoom", property: camera.zoom)
			
			FocusControl(camera: camera, property: camera.focus)
			
			VStack(alignment: .leading) {
				Text("Connections")
				
				ForEach(server.connections) { connection in
					HStack {
						Text("\(connection.connection.endpoint.debugDescription)")
						Spacer()
						Button(action: {
							connection.connection.forceCancel()
						}, label: {
							Text("Disconnect")
						})
					}
				}
			}
			
			Spacer()
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
