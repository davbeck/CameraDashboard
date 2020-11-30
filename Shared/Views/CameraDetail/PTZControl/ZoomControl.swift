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
				DirectionButton(isActive: $client.zoomDirection.equalTo(.wide)) {
					Image(systemSymbol: .minusMagnifyingglass)
				}
				
				if client.allowDirectControl {
					Slider(value: $client.zoomPosition.local, in: 0...VISCAClient.maxZoom)
				} else {
					Spacer()
				}
				
				DirectionButton(isActive: $client.zoomDirection.equalTo(.tele)) {
					Image(systemSymbol: .plusMagnifyingglass)
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
