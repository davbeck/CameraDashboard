import SwiftUI
import Combine

struct ConnectionPresetsRow: View {
	@EnvironmentObject var cameraManager: CameraManager
	@EnvironmentObject var errorReporter: ErrorReporter
	@ObservedObject var client: VISCAClient
	var camera: Camera
	
	var body: some View {
		HStack(spacing: 15) {
			ForEach(VISCAPreset.allCases.prefix(16)) { preset in
				PresetView(
					camera: camera,
					preset: preset,
					client: client
				)
				.frame(width: 140)
				.onTapGesture {
					client.preset.local = preset
				}
				.acceptsFirstMouse()
			}
		}
		.onAppear {
			client.inquirePreset()
		}
	}
}

// struct ConnectionPresetsRow_Previews: PreviewProvider {
//    static var previews: some View {
//        ConnectionPresetsRow()
//    }
// }
