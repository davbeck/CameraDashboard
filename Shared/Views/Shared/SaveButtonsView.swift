import SwiftUI

struct SaveButtonsView: View {
	var save: () -> Void
	var cancel: () -> Void
	
	var body: some View {
		HStack(spacing: 16) {
			Spacer()
			
			Button(action: {
				self.cancel()
			}, label: {
				Text("Cancel")
					.padding(.horizontal, 10)
					.column("Buttons", alignment: .center)
			})
				.keyboardShortcut(.cancelAction)
			
			Button(action: {
				self.save()
			}, label: {
				Text("Save")
					.padding(.horizontal, 10)
					.column("Buttons", alignment: .center)
			})
				.keyboardShortcut(.defaultAction)
		}
		.columnGuide()
	}
}

struct SaveButtonsView_Previews: PreviewProvider {
	static var previews: some View {
		SaveButtonsView(save: {}, cancel: {})
	}
}
