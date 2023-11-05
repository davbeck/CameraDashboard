import MIDIKit
import SwiftUI

struct ActionTriggerEditView: View {
	@Binding var status: MIDIStatus
	@Binding var channel: UInt8
	@Binding var note: UInt8

	var body: some View {
		VStack(alignment: .leading) {
			Text("Trigger")
				.font(.footnote)

			HStack {
				MIDICommandControl(status: $status)

				MIDIChannelControl(channel: $channel)

				MIDINoteControl(
					status: status,
					channel: channel,
					note: $note
				)
			}
		}
	}
}

// struct ActionTriggerEditView_Previews: PreviewProvider {
//	static var previews: some View {
//		ActionTriggerEditView()
//	}
// }
