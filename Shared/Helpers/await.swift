import Combine
import Foundation

struct MissingOutputError: Swift.Error {}
struct TimeoutError: Swift.Error {
    var timeout: TimeInterval
}

extension Publisher {
    func await(delay: TimeInterval? = nil, timeout: TimeInterval = 60) throws -> Output {
        var error: Failure?
        var output: Output?
        var completed = false
        
        let observer = self
            .receive(on: RunLoop.current)
            .sink(receiveCompletion: { completion in
                switch completion {
                case let .failure(e):
                    error = e
                case .finished:
                    break
                }
                
                completed = true
            }, receiveValue: { o in
                output = o
            })
        
        let timeoutEnd = Date(timeIntervalSinceNow: timeout)
        while !completed {
            let until = delay.map { Date(timeIntervalSinceNow: $0) } ?? Date()
            RunLoop.current.run(until: until)
            
            if timeoutEnd.timeIntervalSinceNow < 0 {
                throw TimeoutError(timeout: timeout)
            }
        }
        
        observer.cancel()
        
        if let error = error {
            throw error
        }
        
        guard let finalOutput = output else { throw MissingOutputError() }
        
        return finalOutput
    }
}
