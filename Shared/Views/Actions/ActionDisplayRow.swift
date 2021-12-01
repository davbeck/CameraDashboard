import SwiftUI
import MIDIKit

struct ActionDisplayRow: View {
	@Environment(\.managedObjectContext) var context
	@EnvironmentObject var cameraManager: CameraManager
	
	@ObservedObject var action: Action
	@Binding var isEditing: Bool
	
	var body: some View {
		HStack(alignment: .bottom, spacing: 15) {
			Text(action.name)
				.font(.headline)
				.frame(maxWidth: 150, alignment: .leading)
			
			VStack(alignment: .leading) {
				Text("Trigger")
					.font(.footnote)
					.foregroundColor(.secondary)
				
				HStack {
					Text(action.status.localizedDescription)
			  
					HStack(spacing: 3) {
						Text("Channel")
							.foregroundColor(.secondary)
						Text("\(action.channel + 1)")
					}
			  
					MIDINoteLabel(status: action.status, note: action.note)
				}
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			
			VStack(alignment: .leading, spacing: 0) {
				Text("Behavior")
					.font(.footnote)
					.foregroundColor(.secondary)
				
				if let presetConfig = action.preset {
					HStack {
						Text(presetConfig.camera.displayName)
			   
						HStack(spacing: 3) {
							if presetConfig.color != .gray {
								Circle()
									.fill(Color(presetConfig.color))
									.frame(width: 10, height: 10)
							}
							Text(presetConfig.displayName)
						}
					}
				}
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			
			Button(action: {
				withAnimation {
					isEditing.toggle()
				}
				
				try? context.saveOrRollback()
			}, label: {
				ZStack {
					// include both in layout so the button doesn't change size
					
					Text("Done")
						.opacity(isEditing ? 1 : 0)
					
					Image(systemSymbol: .sliderHorizontal3)
						.opacity(isEditing ? 0 : 1)
				}
			})
				.disabled(isEditing && action.preset == nil)
		}
		.lineLimit(1)
		.padding()
	}
	
	struct MIDINoteLabel: View {
		var status: MIDIStatus
		var note: UInt8
		
		var midiNote: MIDINote {
			MIDINote(rawValue: note)
		}
		
		var body: some View {
			HStack(spacing: 3) {
				if status.usesNote {
					Text("Note")
						.foregroundColor(.secondary)
					Text("\(midiNote.description) (\(midiNote.rawValue))")
				} else {
					Text("Control")
						.foregroundColor(.secondary)
					Text("\(note)")
				}
			}
		}
	}
}

// struct ActionDisplayRow_Previews: PreviewProvider {
//	static var previews: some View {
//		ActionDisplayRow(action: Action(
//			name: "Welcome",
//			status: .noteOn,
//			channel: 2,
//			note: 4,
//			cameraID: CameraManager.shared.connections.randomElement()?.id,
//			preset: VISCAPreset.allCases.randomElement()!,
//			switchInput: true
//		), isEditing: .constant(false))
//			.environmentObject(CameraManager.shared)
//	}
// }
