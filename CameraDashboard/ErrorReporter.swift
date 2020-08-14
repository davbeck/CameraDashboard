//
//  ErrorReporter.swift
//  CameraDashboard
//
//  Created by David Beck on 8/14/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import Foundation
import Combine
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
		self.lastError = error
		
		clearTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: { timer in
			withAnimation(.easeInOut(duration: 0.5)) {
				self.lastError = nil
			}
		})
	}
}

extension Publisher {
	func sink(into reporter: ErrorReporter) {
		self
			.receive(on: RunLoop.main)
			.sink { completion in
				switch completion {
				case .failure(let error):
					reporter.report(error)
				case .finished:
					break
				}
			} receiveValue: { _ in }
			.store(in: &reporter.observers)
	}
}
