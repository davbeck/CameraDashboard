import SwiftUI

struct CameraDetail: View {
	var connection: CameraConnection
	
	var body: some View {
		VStack {
			TabView(content: {
				CameraPTZControlTab(client: connection.client, camera: connection.camera)
			})
			HStack {
				Text("\(connection.camera.address):\(connection.camera.port ?? 5678, formatter: portFormatter)")
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
	}
}

struct CameraDetail_Previews: PreviewProvider {
	static var previews: some View {
		CameraDetail(connection: CameraConnection())
	}
}
