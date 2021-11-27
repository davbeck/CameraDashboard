import ObjectiveC

public extension objc_AssociationPolicy {
	static let retain = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN
	static let retainNonatomic = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
	static let copy = objc_AssociationPolicy.OBJC_ASSOCIATION_COPY
	static let copyNonatomic = objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC
	static let assign = objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN
}

public struct AssociatedProperty<T: Any> {
	fileprivate let key = UnsafeRawPointer(UnsafeMutablePointer<UInt8>.allocate(capacity: 1))
	
	public let defaultValue: T
	public let policy: objc_AssociationPolicy
	
	public init(defaultValue: T, policy: objc_AssociationPolicy = .retain) {
		self.defaultValue = defaultValue
		self.policy = policy
	}
	
	public init<Wrapped>(policy: objc_AssociationPolicy = .retain) where T == Wrapped? {
		self.defaultValue = nil
		self.policy = policy
	}
}

public extension NSObjectProtocol {
	subscript<T>(property: AssociatedProperty<T>) -> T {
		get {
			return objc_getAssociatedObject(self, property.key) as? T ?? property.defaultValue
		}
		set {
			objc_setAssociatedObject(self, property.key, newValue, property.policy)
		}
	}
	
	func lazyLoad<T>(_ property: AssociatedProperty<T>, fallback load: () -> T) -> T {
		if let value = objc_getAssociatedObject(self, property.key) as? T {
			return value
		} else {
			let value = load()
			self[property] = value
			return value
		}
	}
}
