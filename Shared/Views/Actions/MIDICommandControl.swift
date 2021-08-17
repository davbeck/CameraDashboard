import SwiftUI
import MIDIKit

struct MIDICommandControl: View {
	@Binding var status: MIDIStatus
	
	var options: [MIDIStatus] {
		return [
			.noteOn,
			.noteOff,
			.controlChange,
			.programChange,
		]
	}
	
	var body: some View {
		Picker(selection: $status, label: Text("Command")) {
			ForEach(options, id: \.self) { status in
				Text(status.localizedDescription)
			}
		}
	}
}

struct MIDICommandControl_Previews: PreviewProvider {
	static var previews: some View {
		MIDICommandControl(status: .constant(.noteOn))
	}
}
