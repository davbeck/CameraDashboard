import SwiftUI

struct DirectionButton<Content: View>: View {
	@Binding var isActive: Bool
	var content: () -> Content
	
	var body: some View {
		ToggleButton(isPressed: $isActive) {
			ZStack {
				#if os(macOS)
					Spacer().frame(width: 20, height: 20)
				#else
					Spacer().frame(width: 44, height: 44)
				#endif
				Image(systemSymbol: .plusMagnifyingglass)
					.opacity(isActive ? 0.8 : 1)
			}
			.contentShape(Rectangle())
		}
	}
}
