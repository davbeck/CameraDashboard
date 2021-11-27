import SwiftUI
import CoreData

struct ActionEditingRow: View {
	@EnvironmentObject var cameraManager: CameraManager
	@FetchedSetup var setup: Setup
	
	@ObservedObject var action: Action
	@Binding var isEditing: Bool
	
	var body: some View {
		HStack {
			TextField("Name", text: $action.name)
			
			Button(action: {
				guard let context = action.managedObjectContext else { return }
				context.delete(action)
				do {
					try context.save()
				} catch {
					context.rollback()
				}
			}, label: {
				Image(systemSymbol: .trashFill)
			})
			
			Button(action: {
				isEditing = false
			}, label: {
				Text("Done")
			})
			.disabled(action.preset == nil)
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
		
		VStack(alignment: .leading) {
			Text("Behavior")
				.font(.footnote)
			
			HStack {
				Menu("Camera") {
					ForEach(setup.cameras) { camera in
						ActionPresetControl(
							camera: camera,
							selection: $action.preset
						)
					}
				}
				
				Toggle("Switch Input", isOn: $action.switchInput)
			}
		}
		.padding()
	}
}

// struct ActionEditingRow_Previews: PreviewProvider {
//	static var previews: some View {
//		ActionEditingRow(actionID: UUID(), action: .constant(Action()), isEditing: .constant(true))
//			.environmentObject(CameraManager.shared)
//	}
// }
