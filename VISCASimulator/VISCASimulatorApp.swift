import SwiftUI

@main
struct VISCASimulatorApp: App {
	@StateObject var server = VISCAServer(port: 5678)

	var body: some Scene {
		WindowGroup {
			ContentView()
				.frame(minWidth: 400, maxWidth: .infinity, minHeight: 300, maxHeight: .infinity)
				.environmentObject(server.camera)
				.environmentObject(server)
		}
	}
}
