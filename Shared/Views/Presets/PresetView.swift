import SwiftUI

struct PresetStateOverlay: View {
	var isActive: Bool
	var isSwitching: Bool
	
	@State private var animatedOff: Bool = false
	
	var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 15)
				.stroke(Color.blue, lineWidth: 4)
				.opacity(isActive ? 1 : 0)
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
				.opacity(isSwitching ? 1 : 0)
		}
	}
}

#if os(macOS)
	private let isMacOS = true
#else
	private let isMacOS = false
#endif

struct PresetView: View {
	@EnvironmentObject var cameraManager: CameraManager
	
	var camera: Camera
	var preset: VISCAPreset
	@ObservedObject var client: VISCAClient
	
	var presetConfig: PresetConfig {
		cameraManager[camera, preset]
	}
	
	var isActive: Bool {
		client.preset.remote == preset
	}
	
	var isSwitching: Bool {
		client.preset.local == preset
	}
	
	@State var isShowingEdit: Bool = false
	@State var isHovering: Bool = false
	
	var body: some View {
		HStack {
			VStack(spacing: 0) {
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
						
						if isShowingEdit || isHovering || !isMacOS {
							Button(action: {
								self.isShowingEdit = true
							}, label: {
								Image(systemSymbol: .ellipsisCircleFill)
							})
								.buttonStyle(PlainButtonStyle())
								.contentShape(Rectangle())
								.popover(
									isPresented: $isShowingEdit,
									arrowEdge: .bottom
								) {
									PresetEditView(
										camera: camera,
										preset: preset,
										client: client
									)
									.environmentObject(cameraManager)
								}
						}
					}
				}
			}
		}
		.padding(12)
		.foregroundColor(.white)
		.frame(height: 100)
		.background(LinearGradient(gradient: Gradient(colors: [
			Color(white: 1, opacity: 0.1),
			Color(white: 1, opacity: 0),
		]), startPoint: .top, endPoint: .bottom))
		.background(Color(presetConfig.color))
		.cornerRadius(15)
		.overlay(
			PresetStateOverlay(
				isActive: isActive,
				isSwitching: isSwitching
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
