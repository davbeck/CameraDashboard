import Combine
import SwiftUI

struct ConnectionPresetsRow<PresetContent: View>: View {
	@EnvironmentObject var cameraManager: CameraManager
	@EnvironmentObject var switcherManager: SwitcherManager
	@EnvironmentObject var errorReporter: ErrorReporter
	@FetchRequest var presetConfigs: FetchedResults<PresetConfig>

	@ObservedObject var camera: Camera
	var presetContent: (_ presetConfig: PresetConfig) -> PresetContent

	init(
		camera: Camera,
		presetContent: @escaping (PresetConfig) -> PresetContent
	) {
		self.camera = camera
		self.presetContent = presetContent

		_presetConfigs = FetchRequest(
			sortDescriptors: [SortDescriptor(\.rawPreset)],
			predicate: NSPredicate(format: "camera = %@", camera)
		)
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
				ForEach(presetConfigs) { presetConfig in
					presetContent(presetConfig)
						.frame(width: width)
				}
			}
			.frame(width: (CGFloat(presetConfigs.count) * (width + 15)) - 15)
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
