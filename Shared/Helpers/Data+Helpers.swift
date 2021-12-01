import Foundation

extension Data {
	func load<T: FixedWidthInteger>(offset: Int = 0, as: T.Type = T.self) -> T {
		let data = dropFirst(offset)
		var value: T = 0
		_ = Swift.withUnsafeMutableBytes(of: &value) { data.copyBytes(to: $0) }
		return T(bigEndian: value)
	}
	
	func loadBitPadded<T: FixedWidthInteger>(offset: Int = 0, as: T.Type = T.self) -> T {
		var result: T = 0
		let size = MemoryLayout<T>.size * 2
		let data = dropFirst(offset).prefix(size)
		for i in 0 ..< size {
			guard let bit = data.dropLast(i).last else { break }
			result = result | T(bit) << (4 * i)
		}
		
		return T(result)
	}
}

extension FixedWidthInteger {
	var bitPadded: Data {
		let data = withUnsafePointer(to: bigEndian) { pointer in
			pointer.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Self>.size) { pointer in
				(0 ..< MemoryLayout<Self>.size)
					.flatMap { [(pointer[$0] & 0xF0) >> 4, pointer[$0] & 0x0F] }
			}
		}
		
		return Data(data)
	}
}
