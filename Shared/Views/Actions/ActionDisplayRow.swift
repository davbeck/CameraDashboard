import SwiftUI
import MIDIKit

struct ActionDisplayRow: View {
	@EnvironmentObject var cameraManager: CameraManager
	@Config(key: CamerasKey()) var cameras
	
	var action: Action
	@Binding var isEditing: Bool
	
	var body: some View {
		HStack(alignment: .bottom, spacing: 15) {
			if !action.name.isEmpty {
				Text(action.name)
					.font(.headline)
			}
			
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
			
			VStack(alignment: .leading) {
				Text("Behavior")
					.font(.footnote)
					.foregroundColor(.secondary)
				
				HStack {
					Text(cameraManager.connections.first(where: { $0.id == action.cameraID })?.displayName ?? "")
			  
					Text("Preset \(action.preset.rawValue)")
				}
			}
			
			Spacer()
			
			Button(action: {
				isEditing = true
			}, label: {
				Image(systemSymbol: .sliderHorizontal3)
			})
		}
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

struct ActionDisplayRow_Previews: PreviewProvider {
	static var previews: some View {
		ActionDisplayRow(action: Action(
			name: "Welcome",
			status: .noteOn,
			channel: 2,
			note: 4,
			cameraID: CameraManager.shared.connections.randomElement()?.id,
			preset: VISCAPreset.allCases.randomElement()!,
			switchInput: true
		), isEditing: .constant(false))
			.environmentObject(CameraManager.shared)
	}
}
