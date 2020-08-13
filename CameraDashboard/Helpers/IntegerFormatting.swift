//
//  IntegerFormatting.swift
//  CameraDashboard
//
//  Created by David Beck on 8/12/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import Foundation

extension BinaryInteger {
	var binaryDescription: String {
		var binaryString = ""
		var internalNumber = self
		var counter = 0
		
		for _ in 1...self.bitWidth {
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
