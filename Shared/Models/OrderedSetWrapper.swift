import Foundation

struct OrderedSetWrapper<Element: Hashable>: RawRepresentable {
	var orderedSet: NSMutableOrderedSet
	
	var rawValue: NSOrderedSet {
		orderedSet
	}
	
	init(rawValue: NSOrderedSet) {
		self.orderedSet = rawValue.mutableCopy() as! NSMutableOrderedSet
	}
	
	private mutating func mutate(_ actions: (NSMutableOrderedSet) -> Void) {
		if !isKnownUniquelyReferenced(&orderedSet) {
			orderedSet = orderedSet.mutableCopy() as! NSMutableOrderedSet
		}

		actions(orderedSet)
	}
	
	init<C: Collection>(_ collection: C) {
		let set = NSMutableOrderedSet()
		for element in collection {
			set.add(element)
		}
		
		self.init(rawValue: set)
	}
	
	var set: Set<Element> {
		rawValue.set as! Set<Element>
	}
	
	var array: [Element] {
		rawValue.array as! [Element]
	}
	
	mutating func add(_ object: Element) {
		mutate {
			$0.add(object)
		}
	}
}

extension OrderedSetWrapper: RandomAccessCollection {
	typealias Index = Int
	
	var startIndex: Int {
		0
	}
	
	var endIndex: Int {
		rawValue.count
	}
	
	subscript(index: Index) -> Element {
		get {
			return rawValue[index] as! Element
		}
		set {
			mutate {
				$0.setObject(newValue, at: index)
			}
		}
	}
	
	func index(after i: Index) -> Index {
		return i + 1
	}
}

extension OrderedSetWrapper: Hashable {}
