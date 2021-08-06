import SwiftUI

struct PresetSwitchingOverlay: View {
	@State private var animatedOff: Bool = false
	
	var body: some View {
		RoundedRectangle(cornerRadius: 15)
			.stroke(Color.blue, lineWidth: 4)
			.opacity(animatedOff ? 0 : 1)
			.onAppear {
				withAnimation(Animation.linear(duration: 0.2)
					.delay(0.2)
					.repeatForever(autoreverses: true)) {
					self.animatedOff = true
				}
			}
	}
}

struct PresetActiveOverlay: View {
	var body: some View {
		RoundedRectangle(cornerRadius: 15)
			.stroke(Color.blue, lineWidth: 4)
	}
}

struct PresetStateOverlay: View {
	var preset: VISCAPreset
	var selection: VISCAClient.RemoteValue<VISCAPreset?>
	
	var body: some View {
		if preset == selection.remote {
			PresetActiveOverlay()
		} else if preset == selection.local {
			PresetSwitchingOverlay()
		}
	}
}

struct PresetView: View {
	var camera: Camera
	var preset: VISCAPreset
	@ObservedObject var client: VISCAClient
	
	@Config var presetConfig: PresetConfig
	
	@State var isHovering: Bool = false
	
	init(camera: Camera, preset: VISCAPreset, client: VISCAClient) {
		self.camera = camera
		self.preset = preset
		self.client = client
		
		_presetConfig = Config(key: .preset(cameraID: camera.id, preset: preset))
	}
	
	var height: CGFloat {
		#if os(macOS)
			return 100
		#else
			return 120
		#endif
	}
	
	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Text(presetConfig.name)
					.lineLimit(2)
					.font(.headline)
				Spacer()
			}
			Spacer(minLength: 0)
			HStack(alignment: .bottom) {
				Text("Preset \(preset.rawValue)")
					.font(.subheadline)
				Spacer()
				
				EditPresetButton(isHovering: isHovering, camera: camera, preset: preset, client: client)
			}
		}
		.padding(12)
		.foregroundColor(.white)
		.frame(height: height)
		.background(LinearGradient(gradient: Gradient(colors: [
			Color(white: 1, opacity: 0.1),
			Color(white: 1, opacity: 0.0),
		]), startPoint: .top, endPoint: .bottom))
		.background(Color(presetConfig.color))
		.cornerRadius(15)
		.overlay(
			PresetStateOverlay(
				preset: preset,
				selection: client.preset
			)
		)
		.onHover(perform: { hovering in
			isHovering = hovering
		})
	}
}

// struct PresetView_Previews: PreviewProvider {
//	static var previews: some View {
//		Group {
//			PresetView(
//				preset: VISCAPreset.allCases[1],
//				presetConfig: .constant(PresetConfig()),
//				isActive: false,
//				isSwitching: false
//			)
//			.padding()
//
//			PresetView(
//				preset: VISCAPreset.allCases[2],
//				presetConfig: .constant(PresetConfig()),
//				isActive: false,
//				isSwitching: true
//			)
//			.padding()
//
//			PresetView(
//				preset: VISCAPreset.allCases[3],
//				presetConfig: .constant(PresetConfig()),
//				isActive: true,
//				isSwitching: false
//			)
//			.padding()
//		}
//	}
// }
