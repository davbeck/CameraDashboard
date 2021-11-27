import Foundation
import CoreMIDI
import CoreData

extension Switcher {
	static func find(in context: NSManagedObjectContext, withMIDIID midiID: MIDIUniqueID) -> Switcher? {
		if let obj = context.validObjects
			.compactMap({ $0 as? Switcher })
			.first(where: { $0.entity.name == Self.entityName && $0.midiID == midiID }) as? Self
		{
			return obj
		}
		
		let request = self.makeFetchRequest()
		request.predicate = NSPredicate(format: "rawMIDIID = \(midiID)")
		request.returnsObjectsAsFaults = false
		request.fetchLimit = 1
		
		do {
			return try context.fetch(request).first
		} catch {
			return nil
		}
	}
	
	static func create(in context: NSManagedObjectContext, withMIDIID midiID: MIDIUniqueID) -> Switcher {
		let newObject = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! Switcher
		newObject.midiID = midiID
		newObject.inputs = OrderedSetWrapper((0..<4).map { _ in NSEntityDescription.insertNewObject(forEntityName: SwitcherInput.entityName, into: context) as! SwitcherInput })
		
		return newObject
	}
	
	static func findOrCreate(in context: NSManagedObjectContext, withMIDIID midiID: MIDIUniqueID) -> Switcher {
		if let switcher = self.find(in: context, withMIDIID: midiID) {
			return switcher
		}
		
		return self.create(in: context, withMIDIID: midiID)
	}
	
	var midiID: MIDIUniqueID {
		get {
			rawMIDIID.map { MIDIUniqueID(clamping: $0) } ?? 0
		}
		set {
			rawMIDIID = Int32(newValue)
		}
	}
	
	var channel: MIDIChannelNumber {
		get {
			rawChannel.map { MIDIChannelNumber(clamping: $0) } ?? 0
		}
		set {
			rawChannel = Int16(newValue)
		}
	}
	
	var inputs: OrderedSetWrapper<SwitcherInput> {
		get {
			OrderedSetWrapper(rawValue: rawInputs ?? NSOrderedSet())
		}
		set {
			rawInputs = newValue.rawValue
		}
	}
}
