import SwiftUI

extension Angle {
	func normalized() -> Angle {
		// (degrees % 360 + 360) % 360
		Angle.radians(
			(radians.truncatingRemainder(dividingBy: 2 * .pi) + 2 * .pi)
				.truncatingRemainder(dividingBy: 2 * .pi)
		)
	}
}
