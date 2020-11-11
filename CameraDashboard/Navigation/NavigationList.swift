//
//  NavigationList.swift
//  CameraDashboard
//
//  Created by David Beck on 11/10/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import SwiftUI

struct NavigationList: View {
    @EnvironmentObject var cameraManager: CameraManager
    
    var body: some View {
        List {
            NavigationLink(destination: PresetsView().environmentObject(cameraManager)) {
                Text("Presets")
            }
            
            ForEach(cameraManager.connections) { connection in
                NavigationLink(destination: CameraContentView(connection: connection)) {
                    CameraNavigationRow(connection: connection)
                }
            }
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 200)
    }
}

struct NavigationList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationList()
    }
}
