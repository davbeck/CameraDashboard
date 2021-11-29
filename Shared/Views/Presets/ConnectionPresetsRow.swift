import SwiftUI
import Combine

struct ConnectionPresetsRow: View {
	@EnvironmentObject var cameraManager: CameraManager
	@EnvironmentObject var switcherManager: SwitcherManager
	@EnvironmentObject var errorReporter: ErrorReporter
	
	@ObservedObject var client: VISCAClient
	@ObservedObject var camera: Camera
	
	init(client: VISCAClient, camera: Camera) {
		self.client = client
		self.camera = camera
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
		VStack(alignment: .leading, spacing: 5) {
			GeometryReader { proxy in
				Text(camera.displayName)
					.font(.headline)
					.padding(.horizontal)
					.padding(.leading, max(-proxy.frame(in: .named("scrollView")).minX, 0))
			}
			
			LazyHStack(spacing: 15) {
				ForEach(presets) { preset in
					PresetView(
						presetConfig: camera[preset],
						client: client
					)
					.frame(width: width)
					.onTapGesture {
						if client.preset.local == preset {
							switcherManager.select(camera)
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
