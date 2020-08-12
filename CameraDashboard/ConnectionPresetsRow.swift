//
//  ConnectionPresetsRow.swift
//  CameraDashboard
//
//  Created by David Beck on 8/12/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import SwiftUI

struct ConnectionPresetsRow: View {
    var body: some View {
		HStack(spacing: 15) {
			ForEach(0..<255) { index in
				PresetView(isActive: false, isSwitching: false)
			}
			Spacer().frame(width: 0)
		}
    }
}

struct ConnectionPresetsRow_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionPresetsRow()
    }
}
