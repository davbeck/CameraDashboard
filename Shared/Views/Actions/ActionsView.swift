import SwiftUI
import CoreData

struct ActionsView: View {
	@Environment(\.managedObjectContext) private var context
	@FetchedSetup private var setup: Setup
	
	@State private var editingAction: Action? = nil
	
	var body: some View {
		ScrollView {
			LazyVStack {
				ActionsSettingsView()
					.padding(.bottom, 10)
				
				ForEach(setup.actions) { action in
					ActionRow(
						action: action,
						isEditing: $editingAction == action
					)
				}
			}
			.padding()
		}
		#if os(iOS)
			.navigationBarTitle(Text("Actions"), displayMode: .inline)
		#endif
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				Button(action: {
					let action = Action(context: context)
					setup.actions.add(action)
					if let camera = setup.cameras.first, let preset = VISCAPreset.allCases.first {
						action.preset = camera[preset]
					}
					
					try? context.saveOrRollback()
					
					editingAction = action
				}, label: {
					Image(systemSymbol: .plus)
				})
				.disabled(setup.cameras.isEmpty)
			}
		}
	}
}

// struct ActionsView_Previews: PreviewProvider {
//	static var previews: some View {
//		ActionsView()
//			.environmentObject(ActionsManager.shared)
//	}
// }
