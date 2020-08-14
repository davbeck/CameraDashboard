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
			ForEach(VISCAPreset.allCases) { preset in
				PresetView(
					preset: preset,
					presetConfig: $cameraManager[camera, preset],
					isActive: client.currentPreset == preset,
					isSwitching: client.nextPreset == preset
				)
				.onTapGesture {
					client.recall(preset: preset)
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
