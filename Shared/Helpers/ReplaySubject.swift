import Combine
import Foundation

extension Publisher {
	/// Provides a subject that shares a single subscription to the upstream publisher and
	/// replays at most `bufferSize` items emitted by that publisher
	/// - Parameter bufferSize: limits the number of items that can be replayed
	func shareReplay(maxValues: Int? = nil) -> AnyPublisher<Output, Failure> {
		multicast(subject: ReplaySubject(maxValues: maxValues))
			.autoconnect()
			.eraseToAnyPublisher()
	}
}

final class ReplaySubject<Output, Failure: Error>: Subject {
	private var buffer = [Output]()
	private let maxValues: Int?
	private let lock = NSRecursiveLock()

	init(maxValues: Int?) {
		self.maxValues = maxValues
	}

	private var subscriptions = [ReplaySubjectSubscription<Output, Failure>]()
	private var completion: Subscribers.Completion<Failure>?

	func receive<Downstream: Subscriber>(subscriber: Downstream) where Downstream.Failure == Failure, Downstream.Input == Output {
		lock.lock(); defer { lock.unlock() }
		let subscription = ReplaySubjectSubscription<Output, Failure>(downstream: AnySubscriber(subscriber))
		subscriber.receive(subscription: subscription)
		subscriptions.append(subscription)
		subscription.replay(buffer, completion: completion)
	}

	/// Establishes demand for a new upstream subscriptions
	func send(subscription: Subscription) {
		lock.lock(); defer { lock.unlock() }
		subscription.request(.unlimited)
	}

	/// Sends a value to the subscriber.
	func send(_ value: Output) {
		lock.lock(); defer { lock.unlock() }
		buffer.append(value)
		if let maxValues {
			buffer = buffer.suffix(maxValues)
		}
		subscriptions.forEach { $0.receive(value) }
	}

	/// Sends a completion event to the subscriber.
	func send(completion: Subscribers.Completion<Failure>) {
		lock.lock(); defer { lock.unlock() }
		self.completion = completion
		subscriptions.forEach { subscription in subscription.receive(completion: completion) }
	}
}

final class ReplaySubjectSubscription<Output, Failure: Error>: Subscription {
	private let downstream: AnySubscriber<Output, Failure>
	private var isCompleted = false
	private var demand: Subscribers.Demand = .none

	init(downstream: AnySubscriber<Output, Failure>) {
		self.downstream = downstream
	}

	func request(_ newDemand: Subscribers.Demand) {
		demand += newDemand
	}

	func cancel() {
		isCompleted = true
	}

	func receive(_ value: Output) {
		guard !isCompleted, demand > 0 else { return }

		demand += downstream.receive(value)
		demand -= 1
	}

	func receive(completion: Subscribers.Completion<Failure>) {
		guard !isCompleted else { return }
		isCompleted = true
		downstream.receive(completion: completion)
	}

	func replay(_ values: [Output], completion: Subscribers.Completion<Failure>?) {
		guard !isCompleted else { return }
		values.forEach { value in receive(value) }
		if let completion { receive(completion: completion) }
	}
}
