import SwiftUI
import SFSafeSymbols

struct NavigationList: View {
	@EnvironmentObject var cameraManager: CameraManager
	@FetchedSetup var setup: Setup
	
	@SceneStorage("NavigationSelection") var navigationSelection: NavigationSelection = ["presets"]
	
	var body: some View {
		List {
			NavigationLink(
				destination: PresetsView().environmentObject(cameraManager),
				isActive: $navigationSelection[contains: "presets"]
			) {
				Text("Presets")
			}
			
			NavigationLink(
				destination: ActionsView().environmentObject(cameraManager),
				isActive: $navigationSelection[contains: "actions"]
			) {
				Text("Actions")
			}
			
			Section(header: Text("Cameras")) {
				ForEach(setup.cameras) { camera in
					NavigationLink(
						destination: CameraDetail(camera: camera),
						isActive: $navigationSelection[contains: camera.objectID.uriRepresentation().absoluteString]
					) {
						CameraNavigationRow(camera: camera)
					}
					// TODO: open new window
					//                    .onTapGesture(count: 2) {
					//                        CameraWindowManager.shared.open(connection.camera)
					//                    }
				}
			}
			.extend {
				#if os(macOS)
					$0.collapsible(false)
				#else
					$0
				#endif
			}
			
			SwitchersSection(navigationSelection: $navigationSelection)
		}
		.listStyle(SidebarListStyle())
		.extend {
			#if os(macOS)
				$0.toolbar(content: {
					ToolbarItem {
						Spacer()
					}
					ToolbarItem {
						AddCameraButton()
					}
				})
			#else
				$0
					.navigationBarItems(trailing: AddCameraButton())
					.navigationTitle(Text("Dashboard"))
			#endif
		}
		.frame(minWidth: 200)
//		.onReceive(cameraManager.didRemoveCamera) { camera in
//			if navigationSelection.items.contains(camera.id.uuidString) {
//				navigationSelection.items.remove(camera.id.uuidString)
//
//				if navigationSelection.items.isEmpty {
//					navigationSelection = ["presets"]
//				}
//			}
//		}
//		.onReceive(cameraManager.didAddCamera) { camera in
//			navigationSelection = [camera.id.uuidString]
//		}
	}
}

struct NavigationList_Previews: PreviewProvider {
	static var previews: some View {
		NavigationList()
	}
}
