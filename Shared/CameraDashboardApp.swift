import SwiftUI
#if canImport(Mixpanel)
	import Mixpanel
#endif
#if canImport(Sparkle)
	import Sparkle
#endif

@main
struct CameraDashboardApp: App {
	#if os(macOS)
		@NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
	#endif
	
	init() {
		#if canImport(Mixpanel)
			Mixpanel.initialize(token: "e7cc43b7bf7e8336e2c20ccc0f744a62")
		#endif
	}
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.frame(minWidth: 800, minHeight: 500)
				.extend {
					#if os(macOS)
						$0.inspectWindow { window in
							window.standardWindowButton(NSWindow.ButtonType.closeButton)?.isEnabled = false
						}
					#else
						$0
					#endif
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
