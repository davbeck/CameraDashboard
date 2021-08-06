import SwiftUI

struct SwitcherNavigationRow: View {
	@ObservedObject var client: SwitcherClient
	
	var name: String {
		(try? client.device.name()) ?? NSLocalizedString("Switcher", comment: "Default switcher name")
	}
	
	var body: some View {
		HStack {
			Text((try? client.device.name()) ?? "Camera Switcher")
			Spacer()
			if client.isOffline {
				ConnectionStatusIndicator(details: Text("\(name) is offline."))
			}
		}
	}
}

// struct SwitcherNavigationRow_Previews: PreviewProvider {
//    static var previews: some View {
//        SwitcherNavigationRow()
//    }
// }
