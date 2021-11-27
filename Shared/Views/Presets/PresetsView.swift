import SwiftUI

struct PresetsView: View {
	@EnvironmentObject var cameraManager: CameraManager
	@FetchedSetup var setup: Setup
	
	var body: some View {
		ScrollView(.vertical, showsIndicators: true, content: {
			VStack(alignment: .leading, spacing: 10) {
				ForEach(setup.cameras) { camera in
					if let client = cameraManager.connections[camera] {
						ConnectionPresetsRow(
							client: client,
							camera: camera
						)
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
