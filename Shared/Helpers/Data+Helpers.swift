//
//  Data+Helpers.swift
//  VISCASimulator
//
//  Created by David Beck on 11/15/20.
//

import Foundation

extension Data {
    init(bitPadded value: Int16) {
        let bits = UInt16(bitPattern: value)

        self.init([
            UInt8((bits & 0xf000) >> 12),
            UInt8((bits & 0x0f00) >> 8),
            UInt8((bits & 0x00f0) >> 4),
            UInt8((bits & 0x000f) >> 0),
        ])
    }

    func load<T: FixedWidthInteger>(offset: Int = 0, as: T.Type = T.self) -> T {
        let data = self.dropFirst(offset)
        var value: T = 0
        _ = Swift.withUnsafeMutableBytes(of: &value, { data.copyBytes(to: $0)} )
        return T(bigEndian: value)
    }
}
