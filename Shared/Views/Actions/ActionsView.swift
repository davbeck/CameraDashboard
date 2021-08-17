import SwiftUI

struct ActionsView: View {
	@Config(key: .actionIDs()) var actionIDs
	
	var body: some View {
		ScrollView {
			LazyVStack {
				ForEach(actionIDs, id: \.self) { actionID in
					ActionRow(actionID: actionID)
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
					actionIDs.append(UUID())
				}, label: {
					Image(systemSymbol: .plus)
				})
			}
		}
	}
}

struct ActionsView_Previews: PreviewProvider {
	static var previews: some View {
		ActionsView()
	}
}
