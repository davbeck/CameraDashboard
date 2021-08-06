import SwiftUI

struct SwitchersSection: View {
	@EnvironmentObject var switcherManager: SwitcherManager
	
	@Binding var navigationSelection: NavigationSelection
	
	var body: some View {
		Section(header: Text("Switchers")) {
			ForEach(Array(switcherManager.switchers.values)) { client in
				NavigationLink(
					destination: SwitcherDetail(client: client),
					isActive: $navigationSelection[contains: "Switchers-\(client.id)"]
				) {
					SwitcherNavigationRow(client: client)
				}
			}
		}
	}
}

struct SwitchersSection_Previews: PreviewProvider {
	static var previews: some View {
		List {
			SwitchersSection(navigationSelection: .constant([]))
		}
	}
}
