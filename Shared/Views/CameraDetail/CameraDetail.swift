import SwiftUI

struct CameraDetail: View {
	var connection: CameraConnection
	
	var body: some View {
		#if os(macOS)
			VStack {
				TabView {
					CameraPTZControlTab(client: connection.client, camera: connection.camera)
				}
				HStack {
					Text("\(connection.camera.address):\(connection.camera.port, formatter: portFormatter)")
						.font(Font.callout.monospacedDigit())
					
					Spacer()
					
					CameraSettingsButton(camera: connection.camera)
				}
			}
			.padding()
			.frame(
				minWidth: 400,
				maxWidth: .infinity,
				minHeight: 300,
				maxHeight: .infinity
			)
			.id(connection.id)
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

#if DEBUG
	struct CameraDetail_Previews: PreviewProvider {
		static var previews: some View {
			CameraDetail(connection: CameraConnection())
		}
	}
#endif
