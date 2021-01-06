import SwiftUI

struct CameraDetail: View {
	var connection: CameraConnection
	
	var body: some View {
		VStack {
			TabView(content: {
				CameraPTZControlTab(client: connection.client, camera: connection.camera)
			})
			HStack {
				Text("\(connection.camera.address):\(connection.camera.port, formatter: portFormatter)")
					.font(Font.callout.monospacedDigit())
				
				Spacer()
				
				CameraSettingsButton(camera: connection.camera)
			}
		}
		.extend {
			#if os(macOS)
				$0
			#else
				$0.navigationBarTitle(Text(connection.displayName), displayMode: .inline)
			#endif
		}
		.padding()
		.frame(
			minWidth: 400,
			maxWidth: .infinity,
			minHeight: 300,
			maxHeight: .infinity
		)
		.id(connection.id)
	}
}

#if DEBUG
	struct CameraDetail_Previews: PreviewProvider {
		static var previews: some View {
			CameraDetail(connection: CameraConnection())
		}
	}
#endif
