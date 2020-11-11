//
//  CameraWindowManager.swift
//  CameraDashboard
//
//  Created by David Beck on 8/15/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import Foundation
import AppKit
import Combine
import SwiftUI

class CameraWindow: NSWindow {
    let hostingView: NSHostingView<CameraContentView>
    
    init(connection: CameraConnection, cameraNumber: Int) {
        hostingView = NSHostingView(rootView: CameraContentView(connection: connection))
        
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false
        )
        self.center()
        self.setFrameAutosaveName(connection.camera.id.uuidString)
        
        title = connection.displayName
        contentView = hostingView
    }
}

class CameraWindowManager {
    private var observers: Set<AnyCancellable> = []
    private var windowControllers: [UUID: ConnectionWindowController] = [:]
    
    static let shared = CameraWindowManager(cameraManager: .shared)
    let cameraManager: CameraManager
    
    init(cameraManager: CameraManager) {
        self.cameraManager = cameraManager
    }
    
    func start() {
        cameraManager.$connections
            .sink { [weak self] connections in
                guard let self = self else { return }
                
                for connection in connections {
                    if let controller = self.windowControllers[connection.camera.id] {
                        // update
                        controller.window?.title = connection.displayName
                        
                        controller.hostingController.rootView.connection = connection
                    } else {
                        let controller = ConnectionWindowController(connection: connection)
                        controller.window?.title = connection.displayName
                        
                        //						window.makeKeyAndOrderFront(nil)
                        
                        self.windowControllers[connection.camera.id] = controller
                    }
                }
                
                let cameraIDs = connections.map { $0.camera.id }
                for id in self.windowControllers.keys.filter({ !cameraIDs.contains($0) }) {
                    self.windowControllers.removeValue(forKey: id)
                }
            }
            .store(in: &observers)
    }
    
    func open(_ camera: Camera) {
        guard let controller = windowControllers[camera.id] else { return }
        
        controller.showWindow(nil)
    }
}
