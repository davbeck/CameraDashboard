import SwiftUI

struct FocusControl: View {
	@State var isAutoFocusOn: Bool = false
	@State var focus: Double = 0
	
	var body: some View {
		VStack {
			HStack {
				Text("Focus")
				Spacer()
				Toggle(isOn: $isAutoFocusOn) {
					Text("Auto")
				}
			}
			
			HStack {
				Image(systemSymbol: .minusMagnifyingglass)
				
				Slider(value: $focus, in: 0...1)
				
				Image(systemSymbol: .plusMagnifyingglass)
			}
			.font(.headline)
			.disabled(isAutoFocusOn)
			.foregroundColor(.accentColor)
		}
	}
}

struct FocusControl_Previews: PreviewProvider {
	static var previews: some View {
		FocusControl()
	}
}
