import Foundation

let portFormatter: NumberFormatter = {
	let formatter = NumberFormatter()
	formatter.maximumFractionDigits = 0
	formatter.usesGroupingSeparator = false
	return formatter
}()

extension Double: ReferenceConvertible {
	public typealias ReferenceType = NSNumber
}

extension Int: ReferenceConvertible {
	public var debugDescription: String {
		description
	}

	public typealias ReferenceType = NSNumber
}

extension UInt16: ReferenceConvertible {
	public var debugDescription: String {
		description
	}

	public typealias ReferenceType = NSNumber
}
