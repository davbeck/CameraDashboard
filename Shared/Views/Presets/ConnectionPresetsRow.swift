import SwiftUI
import Combine

struct ConnectionPresetsRow: View {
	@EnvironmentObject var cameraManager: CameraManager
	@EnvironmentObject var errorReporter: ErrorReporter
	@ObservedObject var client: VISCAClient
	var camera: Camera
	
	var presets: Array<VISCAPreset>.SubSequence {
		VISCAPreset.allCases.prefix(51)
	}
	
	var body: some View {
		ScrollView(.horizontal, showsIndicators: true) {
			LazyHStack(spacing: 15) {
				ForEach(presets) { preset in
					PresetView(
						camera: camera,
						preset: preset,
						client: client
					)
					.frame(width: 140)
					.onTapGesture {
						client.preset.local = preset
					}
				}
			}
			.frame(width: (CGFloat(presets.count) * (140 + 15)) - 15)
			.padding(.vertical, 5)
			.padding(.horizontal)
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
