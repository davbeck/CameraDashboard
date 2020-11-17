import Foundation

extension BinaryInteger {
	var binaryDescription: String {
		var binaryString = ""
		var internalNumber = self
		var counter = 0
		
		for _ in 1...bitWidth {
			binaryString.insert(contentsOf: "\(internalNumber & 1)", at: binaryString.startIndex)
			internalNumber >>= 1
			counter += 1
		}
		
		return binaryString
	}
}

extension UInt8 {
	var hexDescription: String {
		String(format: "%02X", self)
	}
}

extension UInt16 {
	var hexDescription: String {
		String(format: "%04X", self)
	}
}

extension UInt32 {
	var hexDescription: String {
		String(format: "%08X", self)
	}
}

extension Data {
	var hexDescription: String {
		map { $0.hexDescription }.joined(separator: " ")
	}
}
