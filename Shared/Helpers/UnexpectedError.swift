import Foundation

public struct UnexpectedError: Error, LocalizedError, CustomStringConvertible {
	public let info: String
	public let file: String
	public let line: Int
	public let function: String

	public init(_ info: String = "", file: String = #file, line: Int = #line, function: String = #function) {
		self.info = info
		self.file = file
		self.line = line
		self.function = function
	}

	public var description: String {
		"Unexpected error, \(info) in \(file):\(line) - \(function)"
	}

	public var errorDescription: String? {
		NSLocalizedString("An unexpected error occurred.", comment: "UnexpectedError description.")
	}
}
