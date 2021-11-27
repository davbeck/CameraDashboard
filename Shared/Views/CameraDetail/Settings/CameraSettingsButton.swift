import SwiftUI

struct CameraSettingsButton: View {
	@Environment(\.managedObjectContext) var context
	@EnvironmentObject var cameraManager: CameraManager
	
	var camera: Camera
	
	@State var isSettingsOpen: Bool = false
	@State var childContext: NSManagedObjectContext?
	@State var childCamera: Camera?
	
	var body: some View {
		Button("Settings") {
			self.isSettingsOpen = true
			
			let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
			context.parent = self.context
			childContext = context
			
			childCamera = context.object(with: camera.objectID) as? Camera
		}
		.sheet(isPresented: $childContext != nil) {
			if let context = childContext, let camera = childCamera {
				CameraConnectionSettingsView(camera: camera)
					.environmentObject(cameraManager)
					.environment(\.managedObjectContext, context)
			}
		}
	}
}
