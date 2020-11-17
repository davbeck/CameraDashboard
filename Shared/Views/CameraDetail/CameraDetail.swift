import SwiftUI

struct CameraDetail: View {
	var connection: CameraConnection
	
	var body: some View {
		VStack {
			TabView(content: {
				CameraPTZControlTab(client: connection.client, camera: connection.camera)
			})
			HStack {
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
