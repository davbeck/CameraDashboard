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
				
				Slider(value: $client.zoomPosition, in: 0...1)
				
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
