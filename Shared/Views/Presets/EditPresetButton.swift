import SwiftUI

struct EditPresetButton: View {
	@EnvironmentObject var cameraManager: CameraManager
	
	var isHovering: Bool
	var presetConfig: PresetConfig
	var client: VISCAClient
	
	@State var isShowingEdit: Bool = false
	
	var isVisible: Bool {
		#if os(macOS)
			return isShowingEdit || isHovering
		#else
			return true
		#endif
	}
	
	var body: some View {
		if isVisible {
			Button(action: {
				self.isShowingEdit = true
			}, label: {
				Image(systemName: "ellipsis.circle.fill")
					.extend {
						#if os(macOS)
							$0
						#else
							$0.font(.system(size: 26))
						#endif
					}
			})
			.buttonStyle(PlainButtonStyle())
			.contentShape(Rectangle())
			.popover(
				isPresented: $isShowingEdit,
				arrowEdge: .bottom
			) {
				PresetEditView(
					presetConfig: presetConfig,
					client: client
				)
				.environmentObject(cameraManager)
			}
		}
	}
}
