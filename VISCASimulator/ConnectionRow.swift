import SwiftUI

struct ConnectionRow: View {
	@ObservedObject var connection: VISCAServerConnection

	var body: some View {
		HStack {
			Text("\(connection.connection.endpoint.debugDescription)")
			Spacer()
			Stepper("Drop Requests: \(connection.dropNext)", value: $connection.dropNext)
			Button(action: {
				connection.connection.forceCancel()
			}, label: {
				Text("Disconnect")
			})
		}
	}
}

// struct ConnectionRow_Previews: PreviewProvider {
//    static var previews: some View {
//        ConnectionRow()
//    }
// }
