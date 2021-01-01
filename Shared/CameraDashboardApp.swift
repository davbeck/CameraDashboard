import SwiftUI
import Mixpanel
#if canImport(Sparkle)
	import Sparkle
#endif

@main
struct CameraDashboardApp: App {
	#if os(macOS)
		@NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
	#endif
	
	init() {
		Mixpanel.initialize(token: "e7cc43b7bf7e8336e2c20ccc0f744a62")
	}
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.frame(minWidth: 800, minHeight: 500)
				.inspectWindow { window in
					window.standardWindowButton(NSWindow.ButtonType.closeButton)?.isEnabled = false
				}
		}
		.commands {
			#if canImport(Sparkle)
				CommandGroup(after: CommandGroupPlacement.appSettings) {
					Button(action: {
						SUUpdater.shared()?.checkForUpdates(nil)
					}) {
						Text("Check for Updates...")
					}
				}
			#endif
			CommandGroup(replacing: CommandGroupPlacement.newItem) {}
		}
	}
}
