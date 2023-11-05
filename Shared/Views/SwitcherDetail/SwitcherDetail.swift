import Algorithms
import MIDIKit
import SwiftUI

struct SwitcherDetail: View {
	@EnvironmentObject var cameraManager: CameraManager

	@ObservedObject var switcher: Switcher

	var body: some View {
		VStack {
			Picker(selection: $switcher.channel, label: Text("Channel")) {
				ForEach(UInt8(0) ..< 16, id: \.self) { channel in
					Text("\(channel + 1)")
				}
			}

			ForEach(switcher.inputs) { input in
				InputRow(input: input)
			}
		}
		.padding()
	}

	struct InputRow: View {
		@FetchedSetup var setup: Setup

		@ObservedObject var input: SwitcherInput

		var body: some View {
			HStack {
				Picker(
					selection: $input.camera,
					label: Text("\(input.displayName):")
				) {
					Text("Unassigned").tag(Camera?.none)

					ForEach(setup.cameras) { camera in
						InputCameraRow(input: input, camera: camera)
							.tag(Camera?.some(camera))
					}
				}
			}
		}
	}

	struct InputCameraRow: View {
		@ObservedObject var input: SwitcherInput
		@ObservedObject var camera: Camera

		var body: some View {
			if camera.switcherInput == nil || camera.switcherInput == input || camera.switcherInput?.switcher != input.switcher {
				Text(camera.displayName)
			}
		}
	}
}

// struct SwitcherDetail_Previews: PreviewProvider {
//	static var previews: some View {
//		SwitcherDetail(
//			client: SwitcherClient(
//				device: MIDIDevice.allDevices.filter { $0.isSwitcher }[0],
//				client: try! MIDIClient(name: "Preview")
//			))
//			.environmentObject(CameraManager.shared)
//	}
// }
