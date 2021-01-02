import SwiftUI

struct RemoveCameraButton: View {
	@EnvironmentObject var cameraManager: CameraManager
	
	var removeCamera: () -> Void
	
	@State var window: NSWindow?
	@State var isOpen: Bool = false
	
	var body: some View {
		Button {
			#if os(macOS)
				let alert = NSAlert()
				alert.messageText = "Are you sure you want to remove this camera?"
				alert.addButton(withTitle: "Remove Camera")
				alert.addButton(withTitle: "Cancel")
				alert.alertStyle = .warning
				if let window = window {
					alert.beginSheetModal(for: window) { response in
						if response == .alertFirstButtonReturn {
							removeCamera()
						}
					}
				} else {
					let response = alert.runModal()
					if response == .alertFirstButtonReturn {
						removeCamera()
					}
				}
			#else
				isOpen = true
			#endif
		} label: {
			Text("Remove")
				.padding(.horizontal, 10)
				.inspectWindow { window in
					self.window = window
				}
		}
		.extend {
			#if os(macOS)
				$0
			#else
				$0.alert(isPresented: $isOpen) {
					Alert(
						title: Text("Are you sure you want to remove this camera?"),
						primaryButton: Alert.Button.destructive(Text("Remove Camera"), action: removeCamera),
						dismissButton: .default(Text("Cancel"))
					)
				}
			#endif
		}
	}
}
