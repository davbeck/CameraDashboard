import SwiftUI

struct MIDIChannelControl: View {
	@Binding var channel: UInt8
	
	var body: some View {
		Picker(selection: $channel, label: Text("Channel")) {
			ForEach(UInt8(0) ..< 16, id: \.self) { channel in
				Text("\(channel + 1)")
			}
		}
	}
}

struct MIDIChannelControl_Previews: PreviewProvider {
	static var previews: some View {
		MIDIChannelControl(channel: .constant(3))
	}
}
