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
