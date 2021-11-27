import CoreData
import MIDIKit

extension Action {
	var status: MIDIStatus {
		get {
			MIDIStatus(rawValue: UInt8(rawStatus)) ?? .noteOn
		}
		set {
			rawStatus = Int16(newValue.rawValue)
		}
	}
	
	var channel: UInt8 {
		get {
			UInt8(clamping: rawChannel)
		}
		set {
			rawChannel = Int16(newValue)
		}
	}
	
	var note: UInt8 {
		get {
			UInt8(clamping: rawNote)
		}
		set {
			rawNote = Int16(newValue)
		}
	}
}
