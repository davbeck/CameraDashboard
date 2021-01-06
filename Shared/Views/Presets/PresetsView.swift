import SwiftUI

struct PresetsView: View {
	@EnvironmentObject var cameraManager: CameraManager
	
	var body: some View {
		ScrollView(.vertical, showsIndicators: true, content: {
			VStack(alignment: .leading, spacing: 10) {
				ForEach(cameraManager.connections) { connection in
					VStack(alignment: .leading, spacing: 0) {
						Text(connection.displayName)
							.font(.headline)
							.padding(.horizontal)
						ConnectionPresetsRow(client: connection.client, camera: connection.camera)
					}
				}
				Spacer()
			}
			.padding(.vertical)
		})
			.extend {
				#if os(macOS)
					$0
				#else
					$0.navigationBarTitle(Text("Presets"), displayMode: .inline)
				#endif
			}
	}
}

struct PresetsView_Previews: PreviewProvider {
	static var previews: some View {
		PresetsView()
	}
}
