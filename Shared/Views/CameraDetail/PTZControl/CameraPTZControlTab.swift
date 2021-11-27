import SwiftUI

struct CameraPTZControlTab: View {
	@ObservedObject var client: VISCAClient
	@AppStorage(VISCAClient.vectorSpeedKey) var vectorSpeed: Double = 0.5
	var camera: Camera
	
	var controlColumnSize: CGFloat {
		#if os(macOS)
			return 200
		#else
			return 260
		#endif
	}
	
	var body: some View {
		HStack {
			CameraPresetsGrid(client: client, camera: camera)
				.layoutPriority(1)
			
			Spacer()
			
			VStack {
				PanTiltControl(vector: $client.vector, size: controlColumnSize)
				Slider(value: $vectorSpeed, in: 0...1) {
					Text("Speed:")
				}
				
				Spacer()
				
				ZoomControl(client: client)
				FocusControl(client: client)
			}
			.frame(width: controlColumnSize)
			.padding()
		}
		.tabItem {
			Text("Controls")
		}
	}
}

// struct CameraPTZControlTab_Previews: PreviewProvider {
//	static var previews: some View {
//		CameraPTZControlTab(client: VISCAClient(Camera(address: "")), camera: Camera(address: ""))
//	}
// }
