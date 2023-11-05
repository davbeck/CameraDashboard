import Combine
import Foundation
import SwiftUI

class ErrorReporter: ObservableObject {
	@Published var lastError: Swift.Error?

	fileprivate var observers: Set<AnyCancellable> = []
	private var clearTimer: Timer? {
		didSet {
			oldValue?.invalidate()
		}
	}

	static let shared = ErrorReporter()

	func report(_ error: Swift.Error) {
		lastError = error

		clearTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: { timer in
			withAnimation(.easeInOut(duration: 0.5)) {
				self.lastError = nil
			}
		})
	}
}

extension Publisher {
	func sink(into reporter: ErrorReporter) {
		receive(on: RunLoop.main)
			.sink { completion in
				switch completion {
				case let .failure(error):
					reporter.report(error)
				case .finished:
					break
				}
			} receiveValue: { _ in }
			.store(in: &reporter.observers)
	}
}
