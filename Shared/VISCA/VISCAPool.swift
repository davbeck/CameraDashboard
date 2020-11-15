//
//  VISCAPool.swift
//  CameraDashboard
//
//  Created by David Beck on 11/14/20.
//

import Foundation
import Combine
import Network

private protocol AnyVISCAPoolRequest {
    func run(_ connection: VISCAConnection, completion: @escaping (Swift.Error?) -> Void)
}

class VISCAPool {
    enum Error: Swift.Error, LocalizedError {
        case timeout
        
        var errorDescription: String? {
            switch self {
            case .timeout:
                return "The operation timed out."
            }
        }
    }
    
    private var connections: Set<VISCAConnection> = []
    private var availableConnections: Set<VISCAConnection> = []
    
    let maxConnections: Int
    let host: NWEndpoint.Host
    let port: NWEndpoint.Port
    
    init(host: NWEndpoint.Host, port: NWEndpoint.Port, maxConnections: Int = 3) {
        self.host = host
        self.port = port
        self.maxConnections = maxConnections
    }
    
    func stop() {
        for connection in connections {
            connection.stop()
        }
        connections = []
        availableConnections = []
    }
    
    private class Request<Return>: AnyVISCAPoolRequest {
        private var observers: Set<AnyCancellable> = []
        let work: (VISCAConnection) -> AnyPublisher<Return, Swift.Error>
        let done = CurrentValueSubject<Return?, Swift.Error>(nil)
        
        init(work: @escaping (VISCAConnection) -> AnyPublisher<Return, Swift.Error>) {
            self.work = work
        }
        
        func run(_ connection: VISCAConnection, completion done: @escaping (Swift.Error?) -> Void) {
            connection.start()
                .flatMap {
                    self.work(connection)
                }
                .timeout(.seconds(30), scheduler: RunLoop.main, options: nil, customError: {
                    Error.timeout
                })
                .sink { completion in
                    self.done.send(completion: completion)
                    switch completion {
                    case .finished:
                        done(nil)
                    case .failure(let error):
                        done(error)
                    }
                    
                    for observer in self.observers {
                        observer.cancel()
                    }
                } receiveValue: { value in
                    self.done.send(value)
                }
                .store(in: &observers)
            
            connection.didFail
                .sink { error in
                    self.done.send(completion: .failure(error))
                    done(error)
                    
                    for observer in self.observers {
                        observer.cancel()
                    }
                }
                .store(in: &observers)
        }
    }
    
    private var requests: [AnyVISCAPoolRequest] = []

    private var currentRequestObserver: AnyCancellable?
    
    func aquire<Value>(_ work: @escaping (VISCAConnection) -> AnyPublisher<Value, Swift.Error>) -> AnyPublisher<Value, Swift.Error> {
        let request = Request(work: work)
        requests.append(request)
        
        dequeue()
        
        return request.done
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    private func dequeue() {
        guard !requests.isEmpty else { return }
        
        let connection: VISCAConnection
        if !availableConnections.isEmpty {
            connection = availableConnections.removeFirst()
        } else if connections.count < maxConnections {
            connection = VISCAConnection(host: host, port: port)
        } else {
            return
        }
        
        var request: AnyVISCAPoolRequest? = requests.removeFirst()
        
        request?.run(connection) { error in
            if error != nil {
                self.connections.remove(connection)
                connection.stop()
            } else {
                self.availableConnections.insert(connection)
            }
            
            request = nil
        }
    }
}
