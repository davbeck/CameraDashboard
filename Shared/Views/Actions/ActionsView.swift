import SwiftUI

struct ActionsView: View {
	@Environment(\.configManager) var configManager
	@Config(key: ActionIDsKey()) var actionIDs
	@Config(key: CamerasKey()) var cameras
	
	@State var editingID: UUID?
	
	var body: some View {
		ScrollView {
			LazyVStack {
				ActionsSettingsView()
					.padding(.bottom, 10)
				
				ForEach(actionIDs, id: \.self) { actionID in
					ActionRow(actionID: actionID, isEditing: $editingID.equalTo(actionID))
				}
			}
			.padding()
		}
		.extend {
			#if os(macOS)
				$0
			#else
				$0.navigationBarTitle(Text("Actions"), displayMode: .inline)
			#endif
		}
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				Button(action: {
					let id = UUID()
					let action = Action(
						cameraID: cameras.first?.id
					)
					
					configManager[ActionKey(id: id)] = action
					
					actionIDs.append(id)
					
					editingID = id
				}, label: {
					Image(systemSymbol: .plus)
				})
				.disabled(cameras.isEmpty)
			}
		}
	}
}

struct ActionsView_Previews: PreviewProvider {
	static var previews: some View {
		ActionsView()
			.environmentObject(ActionsManager.shared)
	}
}
