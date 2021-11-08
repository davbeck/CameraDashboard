import SwiftUI
import Combine

struct ConnectionPresetsRow: View {
	@EnvironmentObject var cameraManager: CameraManager
	@EnvironmentObject var switcherManager: SwitcherManager
	@EnvironmentObject var errorReporter: ErrorReporter
	@Config<PresetConfigsKey> var presetConfigs: PresetConfigs
	
	@ObservedObject var client: VISCAClient
	var camera: Camera
	
	init(client: VISCAClient, camera: Camera) {
		self.client = client
		self.camera = camera
		
		_presetConfigs = Config(key: PresetConfigsKey(cameraID: camera.id))
	}
	
	var presets: Array<VISCAPreset>.SubSequence {
		VISCAPreset.allCases.prefix(51)
	}
	
	var width: CGFloat {
		#if os(macOS)
			return 140
		#else
			return 175
		#endif
	}
	
	var body: some View {
		ScrollView(.horizontal, showsIndicators: true) {
			LazyHStack(spacing: 15) {
				ForEach(presets) { preset in
					PresetView(
						presetConfig: presetConfigs[preset],
						camera: camera,
						preset: preset,
						client: client
					)
					.frame(width: width)
					.onTapGesture {
						if client.preset.local == preset {
							switcherManager.selectCamera(id: camera.id)
						}
						client.recall(preset: preset)
					}
				}
			}
			.frame(width: (CGFloat(presets.count) * (width + 15)) - 15)
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
