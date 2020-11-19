import SwiftUI

extension Binding {
	func equalTo<T>(_ value: T) -> Binding<Bool> where Value == T?, T: Equatable {
		Binding<Bool>(get: {
			self.wrappedValue == value
		}, set: { isActive in
			if isActive {
				self.wrappedValue = value
			} else {
				self.wrappedValue = nil
			}
		})
	}
}
