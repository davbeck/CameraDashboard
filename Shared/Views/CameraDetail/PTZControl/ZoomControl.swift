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
				Image(systemSymbol: .minusMagnifyingglass)
				
				Slider(value: $client.zoomPosition.local, in: 0...UInt16.max)
				
				Image(systemSymbol: .plusMagnifyingglass)
			}
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
