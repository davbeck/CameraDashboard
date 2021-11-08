import SwiftUI

struct ActionEditingRow: View {
	@Environment(\.configManager) var configManager
	@EnvironmentObject var cameraManager: CameraManager
	
	var actionID: UUID
	@Binding var action: Action
	@Binding var isEditing: Bool
	
	var body: some View {
		HStack {
			TextField("Name", text: $action.name)
			
			Button(action: {
				configManager[ActionIDsKey()]
					.removeAll(where: { $0 == actionID })
			}, label: {
				Image(systemSymbol: .trashFill)
			})
			
			Button(action: {
				isEditing = false
			}, label: {
				Text("Done")
			})
			.disabled(action.cameraID == nil)
		}
		.padding()
		
		Divider()
		
		VStack(alignment: .leading) {
			Text("Trigger")
				.font(.footnote)
			
			HStack {
				MIDICommandControl(status: $action.status)
				
				MIDIChannelControl(channel: $action.channel)
				
				MIDINoteControl(status: action.status, note: $action.note)
			}
		}
		.padding()
		
		Divider()
		
		VStack(alignment: .leading) {
			Text("Behavior")
				.font(.footnote)
			
			HStack {
				Picker(selection: $action.cameraID, label: Text("Camera")) {
					ForEach(cameraManager.connections) { connection in
						Text(cameraManager.connections.first(where: { $0.id == connection.id })?.displayName ?? "")
							.tag(connection.id as UUID?)
					}
				}
				ActionPresetControl(cameraID: action.cameraID, selection: $action.preset)
				
				Toggle("Switch Input", isOn: $action.switchInput)
			}
		}
		.padding()
	}
}

struct ActionEditingRow_Previews: PreviewProvider {
	static var previews: some View {
		ActionEditingRow(actionID: UUID(), action: .constant(Action()), isEditing: .constant(true))
			.environmentObject(CameraManager.shared)
	}
}
