//
//  ConnectionStatusIndicator.swift
//  CameraDashboard
//
//  Created by David Beck on 8/12/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import SwiftUI

struct ConnectionStatusDetails: View {
	var state: VISCAClient.State
	
	var body: some View {
		switch state {
		case .inactive:
			Text("Inactive")
		case .connecting:
			Text("Connecting...")
		case .error(let error):
			Text(error.localizedDescription)
		case .ready, .executing:
			Text("Ready")
		}
	}
}

struct ConnectionStatusIndicator: View {
	var state: VISCAClient.State
	@State var showPopover: Bool = false
	
	var connectionColor: Color {
		switch state {
		case .inactive:
			return Color.gray
		case .connecting:
			return Color.orange
		case .error:
			return Color.red
		case .ready, .executing:
			return Color.green
		}
	}
	
	var body: some View {
		Circle()
			.fill(connectionColor)
			.onTapGesture(count: 1, perform: {
				showPopover.toggle()
			})
			.frame(width: 10, height: 10)
			.popover(
				isPresented: self.$showPopover,
				arrowEdge: .bottom
			) {
				ConnectionStatusDetails(state: state).padding()
			}
	}
}

struct ConnectionStatusIndicator_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			ConnectionStatusIndicator(state: .inactive)
			ConnectionStatusIndicator(state: .connecting)
			ConnectionStatusIndicator(state: .error(NSError()))
			ConnectionStatusIndicator(state: .ready)
		}
	}
}
