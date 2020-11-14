//
//  CameraSettingsButton.swift
//  CameraDashboard
//
//  Created by David Beck on 11/11/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import SwiftUI

struct CameraSettingsButton: View {
    @EnvironmentObject var cameraManager: CameraManager
    
    var camera: Camera
    
    @State var isSettingsOpen: Bool = false
    
    var body: some View {
        Button("Settings") {
            self.isSettingsOpen = true
        }
        .sheet(isPresented: $isSettingsOpen) {
            CameraConnectionSettingsView(camera: camera, isOpen: $isSettingsOpen)
                .environmentObject(cameraManager)
        }
    }
}
