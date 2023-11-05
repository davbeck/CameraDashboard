import Foundation

extension SwitcherInput {
	var displayName: String {
		if let number = self.switcher.inputs.firstIndex(of: self) {
			String(localized: "Input \(number)")
		} else {
			String(localized: "Input")
		}
	}
}
