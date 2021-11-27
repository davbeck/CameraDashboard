import SwiftUI

struct CameraDetail: View {
	@EnvironmentObject var cameraManager: CameraManager
	
	@ObservedObject var camera: Camera
	
	var body: some View {
		#if os(macOS)
			VStack {
				TabView {
					if let client = cameraManager.connections[camera] {
						CameraPTZControlTab(
							client: client,
							camera: camera
						)
					}
				}
				HStack {
					Group {
						if let port = camera.port {
							Text("\(camera.address):\(port, formatter: portFormatter)")
						} else {
							Text("\(camera.address) (connecting...)")
						}
					}
					.font(Font.callout.monospacedDigit())
					
					Spacer()
					
					CameraSettingsButton(camera: camera)
				}
			}
			.padding()
			.frame(
				minWidth: 400,
				maxWidth: .infinity,
				minHeight: 300,
				maxHeight: .infinity
			)
		#else
			CameraPTZControlTab(client: connection.client, camera: connection.camera)
				.navigationBarTitle(Text(connection.displayName), displayMode: .inline)
				.toolbar(content: {
					ToolbarItem(placement: .bottomBar) {
						Text("\(connection.camera.address):\(connection.camera.port, formatter: portFormatter)")
							.font(Font.callout.monospacedDigit())
					}
					ToolbarItem(placement: .bottomBar) {
						Spacer()
					}
					ToolbarItem(placement: .bottomBar) {
						CameraSettingsButton(camera: connection.camera)
					}
				})
				.id(connection.id)
		#endif
	}
}

// #if DEBUG
//	struct CameraDetail_Previews: PreviewProvider {
//		static var previews: some View {
//			CameraDetail(connection: CameraConnection())
//		}
//	}
// #endif
