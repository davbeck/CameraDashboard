import SwiftUI
import MIDIKit

struct MIDINoteControl: View {
	var status: MIDIStatus
	@Binding var note: UInt8
	
	var body: some View {
		if status.usesNote {
			Picker(selection: $note, label: Text("Note")) {
				ForEach(MIDINote.allCases) { note in
					Text("\(note.description) (\(note.rawValue))")
						.tag(note.rawValue)
				}
			}
		} else {
			Picker(selection: $note, label: Text("Control")) {
				ForEach(UInt8(0)...127, id: \.self) { note in
					Text("\(note)")
				}
			}
		}
	}
}

struct MIDINoteControl_Previews: PreviewProvider {
	static var previews: some View {
		MIDINoteControl(status: .noteOn, note: .constant(3))
		MIDINoteControl(status: .controlChange, note: .constant(3))
	}
}
