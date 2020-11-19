import SwiftUI

struct ZoomControl: View {
	@ObservedObject var client: VISCAClient
	
	var body: some View {
		VStack {
			HStack {
				Text("Zoom")
				Spacer()
			}
			
			HStack {
				ToggleButton(isPressed: $client.zoomDirection.equalTo(.wide)) {
					Image(systemSymbol: .minusMagnifyingglass)
						.opacity(client.zoomDirection == .wide ? 0.8 : 1)
				}
				
				Slider(value: $client.zoomPosition.local, in: 0...UInt16.max)
				
				ToggleButton(isPressed: $client.zoomDirection.equalTo(.tele)) {
					Image(systemSymbol: .plusMagnifyingglass)
						.opacity(client.zoomDirection == .tele ? 0.8 : 1)
				}
			}
			.font(.headline)
			.imageScale(.large)
			.foregroundColor(.accentColor)
		}
		.onAppear {
			client.inquireZoomPosition()
		}
	}
}

// struct ZoomControl_Previews: PreviewProvider {
//    static var previews: some View {
//        ZoomControl()
//    }
// }
