//
//  ConnectionPresetsRow.swift
//  CameraDashboard
//
//  Created by David Beck on 8/12/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import SwiftUI

struct ConnectionPresetsRow: View {
	@EnvironmentObject var cameraManager: CameraManager
	@ObservedObject var client: VISCAClient
	var camera: Camera
	
	var body: some View {
		HStack(spacing: 15) {
			ForEach(cameraManager.presets(for: camera)) { presetConfig in
				PresetView(
					presetConfig: presetConfig,
					isActive: client.currentPreset == presetConfig.preset,
					isSwitching: client.nextPreset == presetConfig.preset
				)
				.onTapGesture {
					client.recall(preset: presetConfig.preset)
				}
			}
			Spacer().frame(width: 0)
		}
	}
}

// struct ConnectionPresetsRow_Previews: PreviewProvider {
//    static var previews: some View {
//        ConnectionPresetsRow()
//    }
// }
