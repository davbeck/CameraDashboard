//
//  VISCAConnection.swift
//  CameraDashboard
//
//  Created by David Beck on 11/14/20.
//

import Foundation
import Combine
import Network

final class VISCAConnection {
    enum Error: Swift.Error, LocalizedError {
        case invalidInitialResponseByte
        case unexpectedBytes
        case missingAck
        case missingCompletion
        case notReady
        case timeout
        
        var errorDescription: String? {
            switch self {
            case .invalidInitialResponseByte:
                return "Received an invalid response from the camera."
            case .unexpectedBytes:
                return "Received unexpected data from the camera."
            case .missingAck:
                return "The camera did not respond."
            case .missingCompletion:
                return "The camera did not respond after updating."
            case .notReady:
                return "The camera is not connected."
            case .timeout:
                return "The operation timed out."
            }
        }
    }
    
    private var observers: Set<AnyCancellable> = []
    
    private let connection: NWConnection
    
    private let didConnect = CurrentValueSubject<Bool, Swift.Error>(false)
    let didFail = PassthroughSubject<Swift.Error, Never>()
    
    init(host: NWEndpoint.Host, port: NWEndpoint.Port) {
        connection = NWConnection(host: host, port: port, using: .tcp)
        
        connection.stateUpdateHandler = { [weak self] state in
            guard let self = self else { return }
            
            print("VISCAClient.stateUpdateHandler", state)
            switch state {
            case .ready:
                self.resetSequence()
                    .sink { completion in
                        switch completion {
                        case .finished:
                            self.didConnect.send(true)
                        case .failure(let error):
                            self.didFail.send(error)
                            self.didConnect.send(completion: .failure(error))
                        }
                    } receiveValue: { _ in }
                    .store(in: &self.observers)
            case .failed(let error):
                self.didFail.send(error)
                self.didConnect.send(completion: .failure(error))
            case .waiting(let error):
                self.didFail.send(error)
                self.didConnect.send(completion: .failure(error))
            case .setup:
                break
            case .preparing:
                break
            case .cancelled:
                break
            @unknown default:
                break
            }
        }
    }
    
    private var hasStarted: Bool = false
    func start() -> AnyPublisher<Void, Swift.Error> {
        if !hasStarted {
            hasStarted = true
            connection.start(queue: .main)
        }
        
        return didConnect
            .filter { $0 }
            .map { _ in () }
            .first()
            .eraseToAnyPublisher()
    }
    
    func stop() {
        connection.cancel()
    }
    
    private var sequence: UInt32 = 1
    
    enum PayloadType {
        case viscaCommand
        case viscaInquery
        case controlCommand
    }
    
    func send(_ type: PayloadType, payload: Data) -> AnyPublisher<Void, Swift.Error> {
        var message = Data()
        // payload type
        switch type {
        case .viscaCommand:
            message.append(0x01)
            message.append(0x00)
        case .viscaInquery:
            message.append(0x01)
            message.append(0x10)
        case .controlCommand:
            message.append(0x02)
            message.append(0x00)
        }
        // payload size
        withUnsafeBytes(of: UInt16(payload.count).bigEndian) { pointer in
            message.append(contentsOf: pointer)
        }
        // sequence number
        withUnsafeBytes(of: sequence.bigEndian) { pointer in
            message.append(contentsOf: pointer)
        }
        
        message.append(payload)
        
        print("⬆️", message.map { $0.hexDescription }.joined(separator: " "))
        
        return connection.send(content: message)
            .mapError { $0 as Swift.Error }
            .map { _ -> Void in
                self.sequence += 1
            }
            .eraseToAnyPublisher()
    }
    
    func receive() -> Future<Data, Swift.Error> {
        let connection = self.connection
        
        return Future<Data, Swift.Error> { promise in
            var responsePacket = Data()
            
            func readByte(completion: @escaping (UInt8) -> Void) {
                connection.receive(minimumIncompleteLength: 1, maximumLength: 1) { data, context, isComplete, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    guard let data = data, data.count == 1 else {
                        connection.cancel()
                        promise(.failure(Error.unexpectedBytes))
                        return
                    }
                    
                    completion(data[0])
                }
            }
            
            func getNext() {
                readByte { byte in
                    if byte == 0xff {
                        print("receiveMessage", responsePacket.hexDescription)
                        promise(.success(responsePacket))
                    } else {
                        responsePacket.append(byte)
                        getNext()
                    }
                }
            }
            
            readByte { byte in
                guard byte == 0x90 else {
                    connection.cancel()
                    promise(.failure(Error.invalidInitialResponseByte))
                    return
                }
                
                getNext()
            }
        }
    }
    
    func sendVISCACommand(payload: Data) -> AnyPublisher<Void, Swift.Error> {
        let payload = Data([0x81]) + payload + Data([0xff])
        
        return send(.viscaCommand, payload: payload)
            .flatMap {
                self.receive()
            }
            .tryMap { (data) -> Void in
                guard data == Data([0x41]) else { throw Error.missingAck }
            }
            .flatMap {
                self.receive()
            }
            .tryMap { (data) -> Void in
                guard data == Data([0x51]) else { throw Error.missingCompletion }
            }
            .timeout(.seconds(10), scheduler: RunLoop.main, customError: {
                Error.timeout
            })
            .disableCancellation()
            .eraseToAnyPublisher()
    }
    
    func sendVISCAInquiry(payload: Data) -> AnyPublisher<Data, Swift.Error> {
        let payload = Data([0x81]) + payload + Data([0xff])
        
        return send(.viscaInquery, payload: payload)
            .flatMap {
                self.receive()
            }
            .timeout(.seconds(10), scheduler: RunLoop.main, customError: {
                Error.timeout
            })
            .disableCancellation()
            .eraseToAnyPublisher()
    }
    
    private func resetSequence() -> AnyPublisher<Void, Swift.Error> {
        send(.controlCommand, payload: Data([0x01]))
            .handleEvents(receiveCompletion: { _ in
                self.sequence = 1
            })
            .disableCancellation()
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}

extension VISCAConnection: Hashable {
    static func == (lhs: VISCAConnection, rhs: VISCAConnection) -> Bool {
        return lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
