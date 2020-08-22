//
//  PTZDirection.swift
//  CameraDashboard
//
//  Created by David Beck on 8/16/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import Foundation
import SwiftUI

enum PTZDirection: CaseIterable {
	case up
	case upRight
	case right
	case downRight
	case down
	case downLeft
	case left
	case upLeft
}

enum PTZVector: Equatable {
	case direction(PTZDirection)
	case relative(angle: Angle, speed: Double)
}
