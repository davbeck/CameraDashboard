import SwiftUI

struct ContentView: View {
	@ObservedObject var cameraManager = CameraManager.shared
	@ObservedObject var errorReporter = ErrorReporter.shared
	@State var isAddingCamera: Bool = false
	
	var body: some View {
		NavigationView {
			NavigationList()
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.environmentObject(cameraManager)
		.environmentObject(errorReporter)
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
