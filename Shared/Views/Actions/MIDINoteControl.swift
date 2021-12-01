import SwiftUI
import MIDIKit

struct MIDINoteControl: View {
	@FetchRequest(sortDescriptors: [SortDescriptor(\Action.rawNote)]) var actions
	
	var status: MIDIStatus
	var channel: UInt8
	@Binding var note: UInt8
	
	var excludedNotes: [UInt8] {
		actions
			.filter { $0.status == status && $0.channel == channel && $0.note != note }
			.map { $0.note }
	}
	
	var body: some View {
		_MIDINoteControl(status: status, channel: channel, excludedNotes: excludedNotes, note: $note)
	}
}

private struct _MIDINoteControl: View {
	var status: MIDIStatus
	var channel: UInt8
	var excludedNotes: [UInt8]
	@Binding var note: UInt8
	
	var body: some View {
		if status.usesNote {
			Picker(selection: $note, label: Text("Note")) {
				ForEach(MIDINote.allCases) { note in
					if !excludedNotes.contains(note.rawValue) {
						Text("\(note.description) (\(note.rawValue))")
							.tag(note.rawValue)
					}
				}
			}
		} else {
			Picker(selection: $note, label: Text("Control")) {
				ForEach(UInt8(0)...127, id: \.self) { note in
					if !excludedNotes.contains(note) {
						Text("\(note)")
					}
				}
			}
		}
	}
}

// struct MIDINoteControl_Previews: PreviewProvider {
//	static var previews: some View {
//		MIDINoteControl(status: .noteOn, note: .constant(3))
//		MIDINoteControl(status: .controlChange, note: .constant(3))
//	}
// }
