import Foundation
import Combine
import Network

extension NWConnection {
	func send(content: Data?, contentContext: NWConnection.ContentContext = .defaultMessage, isComplete: Bool = true) -> Future<Void, NWError> {
		return Future { promise in
			self.send(content: content, contentContext: contentContext, isComplete: isComplete, completion: .contentProcessed { error in
				if let error = error {
					promise(.failure(error))
				} else {
					promise(.success(()))
				}
			})
		}
	}
	
	func receive(minimumIncompleteLength: Int, maximumLength: Int) -> Future<Data, NWError> {
		Future { promise in
			self.receive(minimumIncompleteLength: minimumIncompleteLength, maximumLength: maximumLength) { data, context, isComplete, error in
				if let error = error {
					promise(.failure(error))
				} else if let data = data {
					promise(.success(data))
				}
			}
		}
	}
}
