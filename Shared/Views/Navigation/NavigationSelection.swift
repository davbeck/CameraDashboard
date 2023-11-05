import Foundation

struct NavigationSelection: RawRepresentable, ExpressibleByArrayLiteral {
	var items: Set<String>

	init(arrayLiteral elements: String...) {
		items = Set(elements)
	}

	init(rawValue: String) {
		items = Set(rawValue.split(separator: ",").map(String.init))
	}

	var rawValue: String {
		items.joined(separator: ",")
	}

	subscript(contains key: String) -> Bool {
		get {
			items.contains(key)
		}
		set {
			if newValue {
				items.insert(key)
			} else {
				items.remove(key)
			}
		}
	}
}
