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

func == <Value: Equatable>(_ lhs: Binding<Value?>, _ rhs: Value?) -> Binding<Bool> {
	Binding<Bool>(get: {
		lhs.wrappedValue == rhs
	}, set: { isActive in
		if isActive {
			lhs.wrappedValue = rhs
		} else {
			lhs.wrappedValue = nil
		}
	})
}

prefix func ! (_ binding: Binding<Bool>) -> Binding<Bool> {
	Binding {
		!binding.wrappedValue
	} set: { newValue in
		binding.wrappedValue = !newValue
	}
}

func != <Value: Equatable>(_ lhs: Binding<Value?>, _ rhs: Value?) -> Binding<Bool> {
	!(lhs == rhs)
}
