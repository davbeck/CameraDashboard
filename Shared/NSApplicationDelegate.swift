import Foundation

#if os(macOS)
	import Sparkle
	import LetsMove
	
	class AppDelegate: NSObject, NSApplicationDelegate {
		var window: NSWindow!
		let updater = SUUpdater.shared()
		
		func applicationWillFinishLaunching(_ notification: Notification) {
			updater?.delegate = self
			
			PFMoveToApplicationsFolderIfNecessary()
		}
		
		func applicationDidFinishLaunching(_ aNotification: Notification) {}
		
		func applicationWillTerminate(_ aNotification: Notification) {}
	}
	
	extension AppDelegate: SUUpdaterDelegate {
		func updater(_ updater: SUUpdater, didFinishLoading appcast: SUAppcast) {
			let isoFormatter = ISO8601DateFormatter()
			isoFormatter.formatOptions = .withInternetDateTime
			
			guard
				let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String,
				let items = appcast.items as? [SUAppcastItem],
				let item = items.first(where: { $0.versionString == build }),
				let expiresString = item.propertiesDictionary["expires"] as? String,
				let expires = isoFormatter.date(from: expiresString)
			else { return }
			
			let formatter = DateFormatter()
			formatter.dateStyle = .long
			
			if expires.timeIntervalSinceNow > 0 {
				let alert = NSAlert()
				alert.messageText = NSLocalizedString("This version will expire soon.", comment: "Build expire alert")
				alert.informativeText = String(format: NSLocalizedString("After %@ you will be forced to update to the latest version.", comment: "Build expire alert"), formatter.string(from: expires))
				alert.alertStyle = .warning
				alert.addButton(withTitle: "OK")
				alert.runModal()
			} else {
				let alert = NSAlert()
				alert.messageText = NSLocalizedString("This version has expired.", comment: "Build expire alert")
				alert.informativeText = NSLocalizedString("You must update to the latest version.", comment: "Build expire alert")
				alert.alertStyle = .critical
				alert.addButton(withTitle: "OK")
				alert.runModal()
				
				updater.installUpdatesIfAvailable()
			}
		}
	}
#endif
