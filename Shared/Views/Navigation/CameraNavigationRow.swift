import SwiftUI

struct CameraNavigationRow: View {
	var connection: CameraConnection
	@ObservedObject var client: VISCAClient
	
	init(connection: CameraConnection) {
		self.connection = connection
		client = connection.client
	}
	
	var body: some View {
		HStack {
			Text(connection.displayName)
			Spacer()
			if let error = client.error {
				ConnectionStatusIndicator(error: error)
			}
		}
	}
}

// o
