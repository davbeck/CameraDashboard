//
//  Angle+Additions.swift
//  CameraDashboard
//
//  Created by David Beck on 8/17/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import SwiftUI

extension Angle {
	func normalized() -> Angle {
		// (degrees % 360 + 360) % 360
		Angle.radians(
			(self.radians.truncatingRemainder(dividingBy: 2 * .pi) + 2 * .pi)
				.truncatingRemainder(dividingBy: 2 * .pi)
		)
	}
}
