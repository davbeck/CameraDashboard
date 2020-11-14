//
//  ZoomControl.swift
//  CameraDashboard
//
//  Created by David Beck on 11/11/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import SwiftUI

struct FocusControl: View {
    @State var isAutoFocusOn: Bool = false
    @State var focus: Double = 0
    
    var body: some View {
        VStack {
            HStack {
                Text("Focus")
                Spacer()
                Toggle(isOn: $isAutoFocusOn) {
                    Text("Auto")
                }
            }
            
            HStack {
                Image("minus.magnifyingglass")
                
                Slider(value: $focus, in: 0 ... 1)
                
                Image("plus.magnifyingglass")
            }
            .disabled(isAutoFocusOn)
            .foregroundColor(.accentColor)
        }
    }
}

struct FocusControl_Previews: PreviewProvider {
    static var previews: some View {
        FocusControl()
    }
}
