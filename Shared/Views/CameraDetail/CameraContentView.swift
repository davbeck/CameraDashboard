import SwiftUI

struct CameraContentView: View {
	var cameraManager: CameraManager
	var connection: CameraConnection
	
	var body: some View {
		CameraDetail(connection: connection)
			.environmentObject(cameraManager)
	}
}

#if DEBUG
	struct CameraContentView_Previews: PreviewProvider {
		static var previews: some View {
			CameraContentView(cameraManager: .shared, connection: CameraConnection())
		}
	}
#endif
