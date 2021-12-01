import SwiftUI

struct PresetsControlView: View {
	@EnvironmentObject var cameraManager: CameraManager
	@EnvironmentObject var switcherManager: SwitcherManager
	
	var body: some View {
		PresetsView([.horizontal, .vertical]) { presetConfig in
			if let client = cameraManager.connections[presetConfig.camera] {
				PresetView(
					presetConfig: presetConfig,
					client: client
				)
				.onTapGesture {
					if client.preset.local == presetConfig.preset {
						switcherManager.select(presetConfig.camera)
					}
					client.recall(preset: presetConfig.preset)
				}
			}
		}
		.onAppear {
			for client in cameraManager.connections.values {
				client.inquirePreset()
			}
		}
	}
}
