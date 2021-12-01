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
					guard
						let presetConfig = setup.cameras.first?
						.presetConfigs?
						.min(by: { $0.rawPreset < $1.rawPreset })
					else { return }
					
					let action = NSEntityDescription.insertNewObject(
						forEntityName: Action.entityName,
						into: context
					) as! Action
					setup.actions.add(action)
					action.preset = presetConfig
					
					var actions = setup.actions.filter { $0.status == action.status }
					
					action.channel = actions.map { $0.channel }.max() ?? 0
					actions = actions.filter { $0.channel == action.channel }
					
					if let note = actions.map({ $0.note }).max() {
						action.note = note + 1
					} else {
						action.note = 0
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
