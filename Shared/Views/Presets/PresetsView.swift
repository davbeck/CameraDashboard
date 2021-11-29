import SwiftUI

struct PresetsView: View {
	@EnvironmentObject var cameraManager: CameraManager
	@FetchedSetup var setup: Setup
	
	var body: some View {
		ScrollView([.vertical, .horizontal], showsIndicators: true) {
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
			.background(Color.red)
		}
		.coordinateSpace(name: "scrollView")
		#if os(iOS)
			.navigationBarTitle(Text("Presets"), displayMode: .inline)
		#endif
	}
}

struct PresetsView_Previews: PreviewProvider {
	static var previews: some View {
		PresetsView()
	}
}
