import AppKit
import SwiftUI

#if os(macOS)
	struct NSWindowInspector: NSViewRepresentable {
		let callback: (NSWindow) -> Void
		
		class View: NSView {
			let callback: (NSWindow) -> Void
			
			init(callback: @escaping (NSWindow) -> Void) {
				self.callback = callback
				
				super.init(frame: .zero)
			}
			
			@available(*, unavailable)
			required init?(coder: NSCoder) {
				fatalError("init(coder:) has not been implemented")
			}
			
			override func viewDidMoveToWindow() {
				guard let window = self.window else { return }
				callback(window)
			}
		}
		
		func makeNSView(context: Context) -> View {
			View(callback: callback)
		}
		
		func updateNSView(_ textView: View, context: Context) {}
	}
	
	extension View {
		func inspectWindow(_ callback: @escaping (NSWindow) -> Void) -> some View {
			overlay(NSWindowInspector(callback: callback))
		}
	}
#endif
