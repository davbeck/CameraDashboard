import SwiftUI
import MIDIKit
import CoreData

struct ActionRow: View {
	@ObservedObject var action: Action
	@Binding var isEditing: Bool
	
	var backgroundColor: Color {
		#if os(macOS)
			Color(.alternatingContentBackgroundColors[1])
		#else
			Color(.secondarySystemGroupedBackground)
		#endif
	}
	
	var body: some View {
		VStack(spacing: 0) {
			ActionDisplayRow(action: action, isEditing: $isEditing)
			
			if isEditing || action.preset == nil {
				Divider()
				
				ActionEditingRow(action: action, isEditing: $isEditing)
			}
		}
		.background(backgroundColor)
		.cornerRadius(10)
	}
}

// struct ActionRow_Previews: PreviewProvider {
//	static var previews: some View {
//		Group {
//			ActionRow(actionID: UUID(uuidString: "7FBB540D-8133-40A0-AF24-1AE73FFABD31")!, isEditing: .constant(false))
//			ActionRow(actionID: UUID(uuidString: "7FBB540D-8133-40A0-AF24-1AE73FFABD31")!, isEditing: .constant(true))
//		}
//		.padding()
//		.environmentObject(CameraManager.shared)
//	}
// }
