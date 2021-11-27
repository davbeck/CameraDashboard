import SwiftUI

struct CameraPresetsGrid: View {
	@EnvironmentObject var cameraManager: CameraManager
	@EnvironmentObject var errorReporter: ErrorReporter
	
	@ObservedObject var client: VISCAClient
	@ObservedObject var camera: Camera
	
	init(client: VISCAClient, camera: Camera) {
		self.client = client
		self.camera = camera
	}
	
	var columns: [GridItem] {
		#if os(macOS)
			return [
				GridItem(.adaptive(minimum: 140, maximum: 200)),
			]
		#else
			return [
				GridItem(.adaptive(minimum: 175, maximum: 220)),
			]
		#endif
	}
	
	var body: some View {
		ScrollView {
			LazyVGrid(columns: columns) {
				ForEach(VISCAPreset.allCases) { preset in
					PresetView(
						presetConfig: camera[preset],
						client: client
					)
					.frame(maxWidth: .infinity)
					.onTapGesture {
						client.recall(preset: preset)
					}
					// this causing a crash
					// .acceptsFirstMouse()
				}
			}
			.padding()
		}
		.onAppear {
			client.inquirePreset()
		}
	}
}

// struct CameraPresetsGrid_Previews: PreviewProvider {
//	static var previews: some View {
//		CameraPresetsGrid()
//	}
// }
