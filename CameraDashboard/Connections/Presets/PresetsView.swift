//
//  PresetsView.swift
//  CameraDashboard
//
//  Created by David Beck on 8/12/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import SwiftUI

struct PresetsView: View {
	@EnvironmentObject var cameraManager: CameraManager
	
    var body: some View {
		ScrollView(.horizontal, showsIndicators: true, content: {
			VStack(spacing: 15) {
				ForEach(cameraManager.connections) { connection in
					ConnectionPresetsRow(client: connection.client, camera: connection.camera)
				}
			}
			.padding(.vertical)
		})
    }
}

struct PresetsView_Previews: PreviewProvider {
    static var previews: some View {
        PresetsView()
    }
}
