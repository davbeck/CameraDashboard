import SwiftUI

struct ToggleButton<Content: View>: View {
	@Binding var isPressed: Bool

	let content: () -> Content

	var body: some View {
		content()
			.gesture(
				DragGesture(minimumDistance: 0)
					.onChanged { value in
						self.isPressed = true
					}
					.onEnded { value in
						self.isPressed = false
					}
			)
	}
}

struct ToggleButton_Previews: PreviewProvider {
	struct ContentView: View {
		@State var isPressed: Bool = false

		var body: some View {
			ToggleButton(isPressed: $isPressed) {
				Text("Press Me")
					.foregroundColor(isPressed ? Color.accentColor : Color.primary)
			}
		}
	}

	static var previews: some View {
		ContentView()
	}
}
