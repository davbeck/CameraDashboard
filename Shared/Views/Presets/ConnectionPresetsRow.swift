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
					preset: preset,
					presetConfig: $cameraManager[camera, preset],
					isActive: client.preset.remote == preset,
					isSwitching: client.preset.local == preset
				)
				.frame(width: 140)
				.onTapGesture {
					client.preset.local = preset
				}
				.acceptsFirstMouse()
			}
		}
	}
}

// struct ConnectionPresetsRow_Previews: PreviewProvider {
//    static var previews: some View {
//        ConnectionPresetsRow()
//    }
// }
