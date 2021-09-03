import SwiftUI
import MIDIKit

struct ActionsSettingsView: View {
	@EnvironmentObject var actionsManager: ActionsManager
	
	var body: some View {
		VStack {
			HStack {
				Picker(selection: $actionsManager.input, label: Text("Input"), content: {
					Text("CameraDashboard")
						.tag(nil as MIDIEndpoint?)
					
					ForEach(actionsManager.sources) { source in
						Text((try? source.displayName()) ?? "\(source.id)")
							.tag(source as MIDIEndpoint?)
					}
				})
			}
			
			if let error = actionsManager.inputError {
				Text(error.localizedDescription)
					.foregroundColor(.red)
			}
		}
	}
}

struct ActionsSettingsView_Previews: PreviewProvider {
	static var previews: some View {
		ActionsSettingsView()
			.environmentObject(ActionsManager.shared)
	}
}
