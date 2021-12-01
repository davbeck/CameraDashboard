import SwiftUI
import CoreData

struct ActionEditingRow: View {
	@ObservedObject var action: Action
	
	var body: some View {
		VStack(spacing: 0) {
			HStack {
				TextField("Name", text: $action.name)
				
				ActionDeleteButton(action: action)
			}
			.padding()
		
			Divider()
		
			ActionTriggerEditView(
				status: $action.status,
				channel: $action.channel,
				note: $action.note
			)
			.padding()
		
			Divider()
		
			ActionBehaviorEditView(
				switchInput: $action.switchInput,
				presetConfig: $action.preset
			)
			.padding(.top)
		}
	}
}

// struct ActionEditingRow_Previews: PreviewProvider {
//	static var previews: some View {
//		ActionEditingRow(actionID: UUID(), action: .constant(Action()), isEditing: .constant(true))
//			.environmentObject(CameraManager.shared)
//	}
// }
