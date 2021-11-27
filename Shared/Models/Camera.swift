import CoreData

extension Camera {
	static func create(
		in context: NSManagedObjectContext,
		name: String,
		address: String,
		port: UInt16?
	) -> Camera {
		let newObject = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! Camera
		newObject.name = name
		newObject.address = address
		newObject.port = port
		
		for preset in VISCAPreset.allCases {
			let config = PresetConfig(entity: PresetConfig.entity(), insertInto: context)
			config.preset = preset
			config.camera = newObject
		}
		
		context.setup.cameras.add(newObject)
		
		return newObject
	}
	
	var displayName: String {
		if name.isEmpty {
			if let number = self.setup.cameras.firstIndex(of: self) {
				return String(localized: "Camera \(number)")
			} else {
				return String(localized: "Camera")
			}
		} else {
			return name
		}
	}
	
	var port: UInt16? {
		get {
			rawPort.map { UInt16(clamping: $0) }
		}
		set {
			rawPort = newValue.map { Int32($0) }
		}
	}
	
	subscript(preset: VISCAPreset) -> PresetConfig {
		if let config = self.presetConfigs?.first(where: { $0.preset == preset }) {
			return config
		}
		
		let config = PresetConfig(entity: PresetConfig.entity(), insertInto: self.managedObjectContext)
		config.preset = preset
		config.camera = self
		
		return config
	}
}
