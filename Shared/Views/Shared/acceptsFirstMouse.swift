//
//  acceptsFirstMouse.swift
//  CameraDashboard
//
//  Created by David Beck on 8/19/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import SwiftUI
import Foundation
import Cocoa

class FirstMouseView<Content: View>: NSHostingView<Content> {
	var acceptsFirstMouse: Bool = true
	
	override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
		return acceptsFirstMouse
	}
}

struct AcceptingFirstMouse<Content: View>: NSViewRepresentable {
	typealias NSViewType = FirstMouseView<Content>
	
	var rootView: Content
	var acceptsFirstMouse: Bool
	
	func makeNSView(context: NSViewRepresentableContext<Self>) -> NSViewType {
		return FirstMouseView<Content>(rootView: rootView)
	}
	
	func updateNSView(_ view: NSViewType, context: NSViewRepresentableContext<Self>) {
		view.rootView = rootView
		view.acceptsFirstMouse = acceptsFirstMouse
	}
}

extension View {
	func acceptsFirstMouse(_ acceptsFirstMouse: Bool = true) -> some View {
		AcceptingFirstMouse(rootView: self, acceptsFirstMouse: acceptsFirstMouse)
	}
}