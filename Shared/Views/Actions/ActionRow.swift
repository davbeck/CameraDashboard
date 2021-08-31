import SwiftUI
import MIDIKit

struct ActionRow: View {
	@Config<ActionKey> var action: Action
	
	var actionID: UUID
	@Binding var isEditing: Bool
	
	init(actionID: UUID, isEditing: Binding<Bool>) {
		_action = Config(key: ActionKey(id: actionID))
		self.actionID = actionID
		_isEditing = isEditing
	}
	
	var backgroundColor: Color {
		#if os(macOS)
			Color(.alternatingContentBackgroundColors[1])
		#else
			Color(.secondarySystemGroupedBackground)
		#endif
	}
	
	var body: some View {
		VStack(spacing: 0) {
			if isEditing || action.cameraID == nil {
				ActionEditingRow(actionID: actionID, action: $action, isEditing: $isEditing)
			} else {
				ActionDisplayRow(action: action, isEditing: $isEditing)
			}
		}
		.background(backgroundColor)
		.cornerRadius(10)
	}
}

struct ActionRow_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			ActionRow(actionID: UUID(uuidString: "7FBB540D-8133-40A0-AF24-1AE73FFABD31")!, isEditing: .constant(false))
			ActionRow(actionID: UUID(uuidString: "7FBB540D-8133-40A0-AF24-1AE73FFABD31")!, isEditing: .constant(true))
		}
		.padding()
		.environmentObject(CameraManager.shared)
	}
}
