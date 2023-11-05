import SwiftUI

#if os(macOS)
	import Cocoa
	import Foundation

	class FirstMouseView<Content: View>: NSHostingView<Content> {
		var acceptsFirstMouse: Bool = true

		override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
			acceptsFirstMouse
		}
	}

	struct AcceptingFirstMouse<Content: View>: NSViewRepresentable {
		typealias NSViewType = FirstMouseView<Content>

		var rootView: Content
		var acceptsFirstMouse: Bool

		func makeNSView(context: NSViewRepresentableContext<Self>) -> NSViewType {
			FirstMouseView<Content>(rootView: rootView)
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

#else
	extension View {
		func acceptsFirstMouse(_ acceptsFirstMouse: Bool = true) -> some View {
			self
		}
	}
#endif
