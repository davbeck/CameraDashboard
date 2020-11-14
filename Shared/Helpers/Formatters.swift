//
//  Formatters.swift
//  CameraDashboard
//
//  Created by David Beck on 8/11/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import Foundation


let portFormatter: NumberFormatter = {
	let formatter = NumberFormatter()
	formatter.maximumFractionDigits = 0
	formatter.usesGroupingSeparator = false
	return formatter
}()
