import SwiftUI

struct EditPresetButton: View {
	@EnvironmentObject var cameraManager: CameraManager
	
	var isHovering: Bool
	var camera: Camera
	var preset: VISCAPreset
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
			})
				.buttonStyle(PlainButtonStyle())
				.contentShape(Rectangle())
				.popover(
					isPresented: $isShowingEdit,
					arrowEdge: .bottom
				) {
					PresetEditView(
						camera: camera,
						preset: preset,
						client: client
					)
					.environmentObject(cameraManager)
				}
		}
	}
}
