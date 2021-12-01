import SwiftUI
import Combine

struct ConnectionPresetsRow<PresetContent: View>: View {
	@EnvironmentObject var cameraManager: CameraManager
	@EnvironmentObject var switcherManager: SwitcherManager
	@EnvironmentObject var errorReporter: ErrorReporter
	
	@ObservedObject var camera: Camera
	var presetContent: (_ presetConfig: PresetConfig) -> PresetContent
	
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
					presetContent(camera[preset])
						.frame(width: width)
				}
			}
			.frame(width: (CGFloat(presets.count) * (width + 15)) - 15)
			.padding(.vertical, 5)
			.padding(.horizontal)
		}
	}
}

// struct ConnectionPresetsRow_Previews: PreviewProvider {
//    static var previews: some View {
//        ConnectionPresetsRow()
//    }
// }
