import SwiftUI

struct PresetSwitchingOverlay: View {
	var color: Color
	
	@State private var animatedOff: Bool = false
	
	var body: some View {
		PresetActiveOverlay(color: color)
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
	var color: Color
	
	var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 15)
				.inset(by: -4)
				.strokeBorder(color, lineWidth: 5)
			RoundedRectangle(cornerRadius: 15)
				.strokeBorder(Color.white, lineWidth: 1)
		}
	}
}

enum PresetState {
	case inactive
	case active(Color)
	case switching(Color)
}

struct PresetStateOverlay: View {
	var presetState: PresetState
	
	var body: some View {
		switch presetState {
		case .inactive:
			EmptyView()
		case let .active(color):
			PresetActiveOverlay(color: color)
		case let .switching(color):
			PresetSwitchingOverlay(color: color)
		}
	}
}

struct CorePresetView<MoreButton: View>: View {
	@ObservedObject var presetConfig: PresetConfig
	var presetState: PresetState
	var moreButton: () -> MoreButton
	
	init(
		presetConfig: PresetConfig,
		presetState: PresetState,
		moreButton: @escaping () -> MoreButton
	) {
		self.presetConfig = presetConfig
		self.presetState = presetState
		self.moreButton = moreButton
	}
	
	init(
		presetConfig: PresetConfig,
		presetState: PresetState
	) where MoreButton == EmptyView {
		self.init(
			presetConfig: presetConfig,
			presetState: presetState
		) {
			EmptyView()
		}
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
			Text(presetConfig.name)
				.lineLimit(2)
				.font(.headline)
			
			Spacer(minLength: 0)
			
			HStack(alignment: .bottom) {
				Text("Preset \(presetConfig.preset.rawValue)")
					.font(.subheadline)
				Spacer()
				
				moreButton()
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
			PresetStateOverlay(presetState: presetState)
		)
	}
}

struct PresetView: View {
	@EnvironmentObject var switcherManager: SwitcherManager
	
	@ObservedObject var presetConfig: PresetConfig
	@ObservedObject var client: VISCAClient
	
	@State var isHovering: Bool = false
	
	var highlightColor: Color {
		switcherManager.selectedInputs.contains(where: { $0.camera == presetConfig.camera }) ? .red : .blue
	}
	
	var presetState: PresetState {
		switch presetConfig.preset {
		case client.preset.remote:
			return .active(highlightColor)
		case client.preset.local:
			return .switching(highlightColor)
		default:
			return .inactive
		}
	}
	
	var body: some View {
		CorePresetView(
			presetConfig: presetConfig,
			presetState: presetState
		) {
			EditPresetButton(
				isHovering: isHovering,
				presetConfig: presetConfig,
				client: client
			)
		}
		.onHover(perform: { hovering in
			isHovering = hovering
		})
	}
}

struct PresetView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
//			PresetView(
//				presetConfig: .init(
//					name: "Stage Left",
//					color: .red
//				), camera: Camera(address: "192.168.1.1"),
//				preset: VISCAPreset.allCases[1],
//				client: VISCAClient(Camera(address: "192.168.1.1"))
//			)
			
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
		}
		.environmentObject(SwitcherManager.shared)
		.previewLayout(.sizeThatFits)
	}
}
