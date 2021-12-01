import SwiftUI

struct ActionDeleteButton: View {
	@ObservedObject var action: Action
	
	@State var isConfirming: Bool = false
	
	var body: some View {
		Button(action: {
			isConfirming = true
		}, label: {
			Image(systemSymbol: .trashFill)
		})
			.alert(Text("Are you sure you want to delete this action?"), isPresented: $isConfirming) {
				Button("Cancel", role: .cancel) {}
				Button(action.name.isEmpty ? "Delete Action" : "Delete \(action.name)", role: .destructive) {
					guard let context = action.managedObjectContext else { return }
				
					// fix for race condition crash
					action.setValue(nil, forKey: "setup")
					context.perform {
						context.delete(action)
						try? context.saveOrRollback()
					}
				}
			}
	}
}

// struct ActionDeleteButton_Previews: PreviewProvider {
//    static var previews: some View {
//        ActionDeleteButton()
//    }
// }
