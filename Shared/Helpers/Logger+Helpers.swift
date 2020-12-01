import Foundation
import OSLog

extension Logger {
	init(category: String) {
		self.init(subsystem: "co.davidbeck.CameraDashboard", category: category)
	}
}
