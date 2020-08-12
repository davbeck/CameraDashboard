//
//  CameraConnectionView.swift
//  CameraDashboard
//
//  Created by David Beck on 8/12/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import SwiftUI
import Combine

struct CameraConnectionView: View {
	@ObservedObject var client: VISCAClient
	var camera: Camera
	var cameraNumber: Int
	
	var body: some View {
		_CameraConnectionView(
			state: client.state,
			name: camera.name ?? "Camera \(cameraNumber)"
		)
	}
}

struct _CameraConnectionView: View {
	var state: VISCAClient.State
	var name: String
	
	var body: some View {
		HStack {
			ConnectionStatusIndicator(state: state)
			Text(name)
		}
	}
}

struct CameraConnectionView_Previews: PreviewProvider {
    static var previews: some View {
		Group {
			_CameraConnectionView(
				state: .ready,
				name: "Stage right"
			)
		}
    }
}
