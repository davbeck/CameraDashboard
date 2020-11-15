//
//  ContentView.swift
//  VISCASimulator
//
//  Created by David Beck on 11/15/20.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var server: VISCAServer

    var body: some View {
        Text("Zoom: \(server.cameraState.zoom)")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
