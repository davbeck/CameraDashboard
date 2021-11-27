import SwiftUI

struct ContentView: View {
	var body: some View {
		NavigationView {
			NavigationList()
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.environmentObject(CameraManager.shared)
		.environmentObject(ErrorReporter.shared)
		.environmentObject(SwitcherManager.shared)
		.environmentObject(ActionsManager.shared)
		.onAppear {
			ActionsManager.shared.connect()
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
