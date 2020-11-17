import Foundation
import Combine

struct Uncancellable<Upstream: Publisher>: Publisher {
	typealias Output = Upstream.Output
	typealias Failure = Upstream.Failure
	
	let root: Upstream
	
	init(_ root: Upstream) {
		self.root = root
	}
	
	func receive<S>(subscriber: S) where S: Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
		let subscription = Subscription<S>(root: root, target: subscriber)
		subscriber.receive(subscription: subscription)
	}
	
	class Subscription<Target: Subscriber>: Combine.Subscription, Subscriber where Target.Input == Upstream.Output, Target.Failure == Upstream.Failure {
		typealias Input = Target.Input
		typealias Failure = Target.Failure
		
		let root: Upstream
		var target: Target?
		var observer: AnyCancellable?
		var subscription: Combine.Subscription?
		
		init(root: Upstream, target: Target) {
			self.root = root
			self.target = target
			
			root.subscribe(self)
		}
		
		// MARK: - Subscription
		
		func request(_ demand: Subscribers.Demand) {
			subscription?.request(demand)
		}
		
		func cancel() {
			// don't forward cancel
			target = nil
		}
		
		// MARK: - Subscriber
		
		func receive(subscription: Combine.Subscription) {
			self.subscription = subscription
		}
		
		func receive(_ input: Target.Input) -> Subscribers.Demand {
			return target?.receive(input) ?? .none
		}
		
		func receive(completion: Subscribers.Completion<Target.Failure>) {
			target?.receive(completion: completion)
		}
	}
}

extension Publisher {
	func disableCancellation() -> Uncancellable<Self> {
		return Uncancellable(self)
	}
}
