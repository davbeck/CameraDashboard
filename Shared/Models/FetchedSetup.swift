import SwiftUI
import CoreData

@propertyWrapper
struct FetchedSetup: DynamicProperty {
	@FetchRequest(sortDescriptors: [SortDescriptor(\Setup.name)]) var setups: FetchedResults<Setup>
	@Environment(\.managedObjectContext) var context
	
	var wrappedValue: Setup {
		setups.first ?? context.setup
	}
}
