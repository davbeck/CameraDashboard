import SwiftUI
import MIDIKit
import Algorithms

struct SwitcherDetail: View {
	@ObservedObject var client: SwitcherClient
	@EnvironmentObject var cameraManager: CameraManager
	
	var body: some View {
		VStack {
			ForEach(Array(client.inputs.indexed()), id: \.index) { index, input in
				HStack {
					Picker(selection: $client.inputs[index], label: Text("Input \(index + 1):"), content: {
						Text("Unassigned").tag(SwitcherClient.Input.unassigned)
						
						ForEach(cameraManager.connections) { connection in
							if !client.inputs.contains(.camera(connection.id)) || input == .camera(connection.id) {
								Text(connection.displayName)
									.tag(SwitcherClient.Input.camera(connection.id))
							}
						}
					})
				}
			}
		}
		.padding()
	}
}

struct SwitcherDetail_Previews: PreviewProvider {
	static var previews: some View {
		SwitcherDetail(
			client: SwitcherClient(
				device: MIDIDevice.allDevices.filter { $0.isSwitcher }[0],
				client: try! MIDIClient(name: "Preview")
			))
			.environmentObject(CameraManager.shared)
	}
}
