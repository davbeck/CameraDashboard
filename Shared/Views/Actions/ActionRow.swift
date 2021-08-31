import SwiftUI
import MIDIKit

struct ActionRow: View {
	@EnvironmentObject var cameraManager: CameraManager
	
	@Config<ActionKey> var action: Action
	
	init(actionID: UUID) {
		_action = Config(key: ActionKey(id: actionID))
	}
	
	var backgroundColor: Color {
		#if os(macOS)
			Color(.alternatingContentBackgroundColors[1])
		#else
			Color(.secondarySystemGroupedBackground)
		#endif
	}
	
	var body: some View {
		VStack(spacing: 0) {
			TextField("Name", text: $action.name)
				.padding()
			
			Divider()
			
			VStack(alignment: .leading) {
				Text("Trigger")
					.font(.footnote)
				
				HStack {
					MIDICommandControl(status: $action.status)
					
					MIDIChannelControl(channel: $action.channel)
					
					MIDINoteControl(status: action.status, note: $action.note)
				}
			}
			.padding()
			
			Divider()
			
			VStack(alignment: .leading) {
				Text("Behavior")
					.font(.footnote)
				
				HStack {
					Picker(selection: $action.cameraID, label: Text("Camera")) {
						ForEach(cameraManager.connections) { connection in
							Text(cameraManager.connections.first(where: { $0.id == connection.id })?.displayName ?? "")
								.tag(connection.id as UUID?)
						}
					}
					Picker(selection: $action.preset, label: Text("Preset")) {
						ForEach(VISCAPreset.allCases) { preset in
							Text("Preset \(preset.rawValue)")
								.tag(preset)
						}
					}
					
					Toggle("Switch Input", isOn: $action.switchInput)
				}
			}
			.padding()
		}
		.background(backgroundColor)
		.cornerRadius(10)
	}
}

struct ActionRow_Previews: PreviewProvider {
	static var previews: some View {
		ActionRow(actionID: UUID(uuidString: "7FBB540D-8133-40A0-AF24-1AE73FFABD31")!)
			.padding()
			.environmentObject(CameraManager.shared)
	}
}
