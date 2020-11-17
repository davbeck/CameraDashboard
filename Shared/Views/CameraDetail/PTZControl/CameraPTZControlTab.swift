import SwiftUI

struct CameraPTZControlTab: View {
	@ObservedObject var client: VISCAClient
	var camera: Camera
	
	var body: some View {
		HStack {
			Spacer()
				.layoutPriority(1)
			VStack {
				PanTiltControl(vector: $client.vector)
				Slider(value: $client.vectorSpeed, in: 0...1) {
					Text("Speed:")
				}
				.frame(width: 200)
				
				Spacer()
				
				ZoomControl(client: client)
				FocusControl()
			}
		}
		.padding()
		.tabItem {
			Text("Controls")
		}
	}
}

struct CameraPTZControlTab_Previews: PreviewProvider {
	static var previews: some View {
		CameraPTZControlTab(client: VISCAClient(Camera(address: "")), camera: Camera(address: ""))
	}
}
