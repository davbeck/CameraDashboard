import CoreData

extension NSManagedObjectContext {
	func saveOrRollback() throws {
		guard hasChanges else { return }
		
		do {
			// this can be extremely helpful when tracking down extraneous changes
			// logChanges()
			
			try save()
		} catch {
			print("Could not save context, rolling back", error)
			rollback()
			throw error
		}
	}
	
	var validObjects: LazyFilterSequence<LazySequence<Set<NSManagedObject>>.Elements> {
		return registeredObjects.lazy.filter { !$0.isFault && !$0.isDeleted }
	}
}
