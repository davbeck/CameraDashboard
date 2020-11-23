import SwiftUI

struct FocusControl: View {
	@ObservedObject var client: VISCAClient
	
	var body: some View {
		VStack {
			HStack {
				Text("Focus")
				Spacer()
				Toggle(isOn: Binding(get: {
					client.focusMode.local == .auto
					}, set: { isOn in
						if isOn {
							client.focusMode.local = .auto
						} else {
							client.focusMode.local = .manual
						}
				})) {
					Text("Auto")
				}
			}
			
			HStack {
				DirectionButton(isActive: $client.focusDirection.equalTo(.far)) {
					Image(systemSymbol: .minus)
				}
				
				Slider(value: $client.focusPosition.local, in: 0...VISCAClient.maxFocus)
				
				DirectionButton(isActive: $client.focusDirection.equalTo(.near)) {
					Image(systemSymbol: .plus)
				}
			}
			.disabled(client.focusMode.local == .auto)
			.font(.headline)
			.imageScale(.large)
			.foregroundColor(.accentColor)
		}
		.onAppear {
			client.inquireFocusPosition()
			client.inquireFocusMode()
		}
	}
}

// struct FocusControl_Previews: PreviewProvider {
//	static var previews: some View {
//		FocusControl()
//	}
// }
