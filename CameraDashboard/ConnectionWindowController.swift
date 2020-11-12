//
//  ConnectionWindowController.swift
//  CameraDashboard
//
//  Created by David Beck on 8/15/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import Cocoa
import SwiftUI

class ConnectionWindowController: NSWindowController {
    let hostingController: NSHostingController<CameraContentView>
    
    init(cameraManager: CameraManager, connection: CameraConnection) {
        hostingController = NSHostingController(rootView: CameraContentView(
            cameraManager: cameraManager,
            connection: connection
        ))
        let window = NSWindow(contentViewController: hostingController)
        
        super.init(window: window)
        
        self.windowFrameAutosaveName = connection.camera.id.uuidString
        shouldCascadeWindows = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
}
