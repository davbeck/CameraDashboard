import SwiftUI

#if os(macOS)
	class AppDelegate: NSObject, NSApplicationDelegate {
		var window: NSWindow!
		
		func applicationDidFinishLaunching(_ aNotification: Notification) {}
		
		func applicationWillTerminate(_ aNotification: Notification) {}
	}
#endif

@main
struct CameraDashboardApp: App {
	#if os(macOS)
		@NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
	#endif
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.frame(minWidth: 800, minHeight: 500)
				.inspectWindow { window in
					window.standardWindowButton(NSWindow.ButtonType.closeButton)?.isEnabled = false
				}
		}
		.commands {
			CommandGroup(replacing: CommandGroupPlacement.newItem) {}
		}
	}
}
