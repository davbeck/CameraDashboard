import SwiftUI

extension View {
	func extend<Content: View>(@ViewBuilder _ content: (_ view: Self) -> Content) -> Content {
		return content(self)
	}
}
