import SwiftUI

struct ConnectionStatusIndicator<Details: View>: View {
	var details: Details

	@State var showPopover: Bool = false

	init(error: Error) where Details == Text {
		self.details = Text(error.localizedDescription)
	}

	init(details: Details) {
		self.details = details
	}

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
				details.padding()
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
