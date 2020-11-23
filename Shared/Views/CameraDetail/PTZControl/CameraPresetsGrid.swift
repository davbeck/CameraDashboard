import SwiftUI

struct CameraPresetsGrid: View {
	@EnvironmentObject var cameraManager: CameraManager
	@EnvironmentObject var errorReporter: ErrorReporter
	@ObservedObject var client: VISCAClient
	var camera: Camera
	
	let columns = [
		GridItem(.adaptive(minimum: 140, maximum: 200)),
	]
	
	var body: some View {
		ScrollView {
			LazyVGrid(columns: columns) {
				ForEach(VISCAPreset.allCases) { preset in
					PresetView(
						preset: preset,
						presetConfig: $cameraManager[camera, preset],
						isActive: client.preset.remote == preset,
						isSwitching: client.preset.local == preset
					)
					.frame(maxWidth: .infinity)
					.onTapGesture {
						client.preset.local = preset
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
