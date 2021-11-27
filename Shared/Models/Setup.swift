import CoreData

private let setupProperty = AssociatedProperty<Setup?>()

extension NSManagedObjectContext {
	var setup: Setup {
		if let setup = self[setupProperty] {
			return setup
		} else if let setup = try? fetch(Setup.makeFetchRequest()).first {
			self[setupProperty] = setup
			return setup
		} else {
			let setup = NSEntityDescription.insertNewObject(forEntityName: Setup.entityName, into: self) as! Setup
			self[setupProperty] = setup
			
			return setup
		}
	}
}

extension Setup {
	var cameras: OrderedSetWrapper<Camera> {
		get {
			OrderedSetWrapper(rawValue: rawCameras ?? NSOrderedSet())
		}
		set {
			rawCameras = newValue.rawValue
		}
	}
	
	var actions: OrderedSetWrapper<Action> {
		get {
			OrderedSetWrapper(rawValue: rawActions ?? NSOrderedSet())
		}
		set {
			rawActions = newValue.rawValue
		}
	}
}
