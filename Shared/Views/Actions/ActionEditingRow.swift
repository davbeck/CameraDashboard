import SwiftUI
import CoreData

struct ActionEditingRow: View {
	@Environment(\.managedObjectContext) var context
	@EnvironmentObject var cameraManager: CameraManager
	@FetchedSetup var setup: Setup
	
	@ObservedObject var action: Action
	
	var body: some View {
		VStack(spacing: 0) {
			HStack {
				TextField("Name", text: $action.name)
			
				ActionDeleteButton(action: action)
			}
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
		
			VStack(alignment: .leading, spacing: 0) {
				HStack {
					Text("Behavior")
						.font(.footnote)
					
					Spacer()
					
					Toggle("Switch Input", isOn: $action.switchInput)
				}
				.padding(.horizontal)
				
				PresetsView { presetConfig in
					CorePresetView(
						presetConfig: presetConfig,
						presetState: action.preset == presetConfig ? .active(Color.green) : .inactive
					)
					.onTapGesture {
						action.preset = presetConfig
					}
				}
			}
			.padding(.top)
		}
	}
}

// struct ActionEditingRow_Previews: PreviewProvider {
//	static var previews: some View {
//		ActionEditingRow(actionID: UUID(), action: .constant(Action()), isEditing: .constant(true))
//			.environmentObject(CameraManager.shared)
//	}
// }
