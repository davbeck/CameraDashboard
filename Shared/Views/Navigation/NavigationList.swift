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
	}
}

struct NavigationList_Previews: PreviewProvider {
	static var previews: some View {
		NavigationList()
	}
}
