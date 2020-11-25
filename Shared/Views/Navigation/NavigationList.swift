import SwiftUI
import SFSafeSymbols

struct NavigationList: View {
	@EnvironmentObject var cameraManager: CameraManager
	
	@SceneStorage("NavigationSelection") var navigationSelection: NavigationSelection = ["presets"]
	
	var body: some View {
		List {
			Section {
				NavigationLink(
					destination: PresetsView().environmentObject(cameraManager),
					isActive: $navigationSelection[contains: "presets"]
				) {
					Text("Presets")
				}
			}
			.collapsible(false)
			
			Section(header: Text("Cameras")) {
				ForEach(cameraManager.connections) { connection in
					NavigationLink(
						destination: CameraDetail(connection: connection),
						isActive: $navigationSelection[contains: connection.id.uuidString]
					) {
						CameraNavigationRow(connection: connection)
					}
					// TODO: open new window
					//                    .onTapGesture(count: 2) {
					//                        CameraWindowManager.shared.open(connection.camera)
					//                    }
				}
			}
			.collapsible(false)
		}
		.listStyle(SidebarListStyle())
		.toolbar(content: {
			ToolbarItem {
				Spacer()
			}
			ToolbarItem {
				AddCameraButton()
			}
		})
		.frame(minWidth: 200)
		.onReceive(cameraManager.didRemoveCamera) { camera in
			if navigationSelection.items.contains(camera.id.uuidString) {
				navigationSelection.items.remove(camera.id.uuidString)
				
				if navigationSelection.items.isEmpty {
					navigationSelection = ["presets"]
				}
			}
		}
		.onReceive(cameraManager.didAddCamera) { camera in
			navigationSelection = [camera.id.uuidString]
		}
	}
}

struct NavigationList_Previews: PreviewProvider {
	static var previews: some View {
		NavigationList()
	}
}
