import SwiftUI

struct PresetsView<PresetContent: View>: View {
	@FetchedSetup var setup: Setup

	var axes: Axis.Set = .horizontal
	@ViewBuilder var presetContent: (_ presetConfig: PresetConfig) -> PresetContent

	init(
		_ axes: Axis.Set = .horizontal,
		@ViewBuilder presetContent: @escaping (PresetConfig) -> PresetContent
	) {
		self.axes = axes
		self.presetContent = presetContent
	}

	var body: some View {
		ScrollView([.horizontal, .vertical], showsIndicators: true) {
			VStack(alignment: .leading, spacing: 10) {
				ForEach(setup.cameras) { camera in
					ConnectionPresetsRow(
						camera: camera,
						presetContent: presetContent
					)
				}
			}
			.padding(.vertical)
		}
		.coordinateSpace(name: "scrollView")
		#if os(iOS)
			.navigationBarTitle(Text("Presets"), displayMode: .inline)
		#endif
	}
}

// struct PresetsView_Previews: PreviewProvider {
//	static var previews: some View {
//		PresetsView() {
//			CorePresetView(presetConfig: <#T##PresetConfig#>, presetState: <#T##PresetState#>)
//		}
//	}
// }
