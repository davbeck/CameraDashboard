import SwiftUI
#if canImport(Sparkle)
	import Sparkle
#endif

@main
struct CameraDashboardApp: App {
	#if os(macOS)
		@NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
	#endif

	init() {}

	var body: some Scene {
		WindowGroup {
			ContentView()
				.frame(minWidth: 800, minHeight: 500)
			#if os(macOS)
				.inspectWindow { window in
					window.standardWindowButton(NSWindow.ButtonType.closeButton)?.isEnabled = false
				}
			#endif
				.environment(\.managedObjectContext, PersistentContainer.shared.viewContext)
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
