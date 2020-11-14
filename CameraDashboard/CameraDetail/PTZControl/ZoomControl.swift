//
//  ZoomControl.swift
//  CameraDashboard
//
//  Created by David Beck on 11/11/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import SwiftUI

struct ZoomControl: View {
    @State var zoom: Double = 0
    
    var body: some View {
        VStack {
            HStack {
                Text("Zoom")
                Spacer()
            }
            
            HStack {
                Image("minus.magnifyingglass")
                
                Slider(value: $zoom, in: 0 ... 1)
                
                Image("plus.magnifyingglass")
            }
            .foregroundColor(.accentColor)
        }
    }
}

struct ZoomControl_Previews: PreviewProvider {
    static var previews: some View {
        ZoomControl()
    }
}
