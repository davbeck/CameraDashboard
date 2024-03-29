import CoreData
import MIDIKit
import SwiftUI

struct ActionRow: View {
	@ObservedObject var action: Action
	@Binding var isEditing: Bool

	var backgroundColor: Color {
		#if os(macOS)
			Color.secondary.opacity(0.05)
		#else
			Color(.secondarySystemGroupedBackground)
		#endif
	}

	var body: some View {
		VStack(spacing: 0) {
			ActionDisplayRow(action: action, isEditing: $isEditing)

			if isEditing {
				Divider()

				ActionEditingRow(action: action)
			}
		}
		.background(backgroundColor)
		.cornerRadius(10)
		.id(action.objectID)
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
