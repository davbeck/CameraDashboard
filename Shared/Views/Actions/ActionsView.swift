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
					action.setup = setup
					if let camera = setup.cameras.first, let preset = VISCAPreset.allCases.first {
						// prefer a preset that has actually been set
						action.preset = camera.presetConfigs?.first(where: { !$0.name.isEmpty || $0.color != .gray }) ?? camera[preset]
					}
					
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
