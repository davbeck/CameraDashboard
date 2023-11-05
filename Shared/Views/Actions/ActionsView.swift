import CoreData
import SwiftUI

struct ActionsView: View {
	@Environment(\.managedObjectContext) private var context
	@FetchedSetup private var setup: Setup

	@State private var editingAction: Action? = nil

	var body: some View {
		ScrollViewReader { scrollProxy in
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

						action.channel = actions.map(\.channel).max() ?? 0
						actions = actions.filter { $0.channel == action.channel }

						if let note = actions.map(\.note).max() {
							action.note = note + 1
						} else {
							action.note = 0
						}

						try? context.saveOrRollback()

						editingAction = action

						Task {
							try await Task.sleep(nanoseconds: 100)

							withAnimation {
								scrollProxy.scrollTo(action.objectID, anchor: .center)
							}
						}
					}, label: {
						Image(systemSymbol: .plus)
					})
					.disabled(setup.cameras.isEmpty)
				}
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
