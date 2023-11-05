import CoreData

private let modelName = "Model"

class PersistentContainer: NSPersistentContainer {
	static var defaultStoreURL: URL {
		self.defaultDirectoryURL()
			.appendingPathComponent(modelName)
			.appendingPathExtension("sqlite3")
	}

	private(set) var storeURL: URL?

	static let shared = PersistentContainer(storeURL: defaultStoreURL)

	init(storeURL: URL? = nil) {
		guard
			let momURL = Bundle(for: type(of: self)).url(forResource: modelName, withExtension: "momd"),
			let managedObjectModel = NSManagedObjectModel(contentsOf: momURL)
		else { fatalError("missing core data model") }

		self.storeURL = storeURL
		if let storeURL {
			print("storeURL: \(storeURL.path)")
		}

		super.init(name: modelName, managedObjectModel: managedObjectModel)

		loadPersistentStore {
			do {
				let context = self.viewContext
				let setups = try context.fetch(Setup.makeFetchRequest())
				for setup in setups.dropFirst() {
					context.delete(setup)
				}

				// create and cache a setup if needed
				_ = context.setup

				try context.saveOrRollback()
			} catch {
				print("failed to create setups", error)
			}
		}

		viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
		viewContext.shouldDeleteInaccessibleFaults = true
		viewContext.automaticallyMergesChangesFromParent = true
	}

	private func loadPersistentStore(completion: @escaping () -> Void) {
		if let storeURL {
			let description = NSPersistentStoreDescription(url: storeURL)
			persistentStoreDescriptions = [description]
		} else {
			let description = NSPersistentStoreDescription()
			description.type = NSInMemoryStoreType
			persistentStoreDescriptions = [description]
		}

		loadPersistentStores { _, error in
			guard let error else { return completion() } // success

			if let storeURL = self.storeURL {
				print("loadPersistentStores failed, deleting store and trying again", error)
				try? FileManager.default.removeItem(at: storeURL.deletingLastPathComponent())

				self.loadPersistentStores(completionHandler: { _, error in
					guard let error else { return } // success
					print("loadPersistentStores failed, reverting to in memory store", error)

					self.storeURL = nil
					self.loadPersistentStore(completion: completion)
				})
			} else {
				print("loadPersistentStores failed in memory, crashing", error)
				fatalError("Could not initialize CoreData stack: \(error)")
			}
		}
	}
}
