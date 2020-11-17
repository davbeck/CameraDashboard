import SwiftUI

struct ConnectionStatusIndicator: View {
	var error: Swift.Error
	@State var showPopover: Bool = false
	
	var body: some View {
		Circle()
			.fill(Color.red)
			.onTapGesture(count: 1, perform: {
				showPopover.toggle()
			})
			.frame(width: 10, height: 10)
			.popover(
				isPresented: self.$showPopover,
				arrowEdge: .bottom
			) {
				Text(error.localizedDescription).padding()
			}
	}
}

struct ConnectionStatusIndicator_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			ConnectionStatusIndicator(error: NSError())
		}
	}
}
