//
//  CameraContentView.swift
//  CameraDashboard
//
//  Created by David Beck on 8/15/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import SwiftUI

struct CameraContentView: View {
    var cameraManager: CameraManager
    var connection: CameraConnection
    
    var body: some View {
        CameraDetail(connection: connection)
        .environmentObject(cameraManager)
    }
}

struct CameraContentView_Previews: PreviewProvider {
    static var previews: some View {
        CameraContentView(cameraManager: .shared, connection: CameraConnection())
    }
}
