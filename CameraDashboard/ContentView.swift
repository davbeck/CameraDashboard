//
//  ContentView.swift
//  Canera Switcher
//
//  Created by David Beck on 8/4/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import SwiftUI

struct ContentView: View {
	@ObservedObject var cameraManager = CameraManager.shared
	
	var body: some View {
		VStack {
			HStack(alignment: .top) {
				CameraHeadingView()
				
				PresetsView()
			}
		}
		.frame(minWidth: 600, minHeight: 300)
		.fixedSize(horizontal: false, vertical: true)
		.environmentObject(cameraManager)
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
