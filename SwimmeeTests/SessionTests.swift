//
//  SessionTests.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 07/11/2022.
//

import Combine
import XCTest

@testable import Swimmee

class ConnectionServiceMock: ConnectionServiceProtocol {
    let statusCycle: [ConnectionStatus]
    
    init(statusCycle: [ConnectionStatus] = []) {
        self.statusCycle = statusCycle
    }
    
    func statusPublisher() -> AnyPublisher<ConnectionStatus, Never> {
        statusCycle.publisher.eraseToAnyPublisher()
        
//        return Just(ConnectionStatus.undefined).eraseToAnyPublisher()
    }
}

enum ConnectionError: LocalizedError {
    case badAuthentication
    
    var errorDescription: String? {
        "Bad authentication"
    }
}

final class SessionTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func waitForConnectionStatusFlow(entry entryFlow: [ConnectionStatus], expectedFlow: [ConnectionStatus]) {
        let connectionServiceDouble = ConnectionServiceMock(statusCycle: entryFlow)
        let session = Session(connectionService: connectionServiceDouble)
                
        assertPublishedValues(session.$connectionStatus, equals: expectedFlow) {
            _ = entryFlow.publisher.sink {
                session.updateConnectionStatus($0)
            }
        }
    }
    
    func testSessionConnectionStatus_When() throws {
        let normalStatusFlow: [ConnectionStatus] = [.undefined, .signedOut, .signedIn(Profile.coachSample), .signedOut]
        
        waitForConnectionStatusFlow(entry: normalStatusFlow, expectedFlow: normalStatusFlow)
    }
    
    func testConnectionStatusWhenDifferentValueArePublished3() throws {
        let entryStatusFlow: [ConnectionStatus] = [.undefined, .undefined, .signedOut, .signedOut, .signedIn(Profile.coachSample), .signedIn(Profile.coachSample), .signedOut]
        let expectedStatusFlow: [ConnectionStatus] = [.undefined, .signedOut, .signedIn(Profile.coachSample), .signedOut]

        waitForConnectionStatusFlow(entry: entryStatusFlow, expectedFlow: expectedStatusFlow)
    }
    
    func testAlertAppear_WhenConnectionStatusIsUpdatedToFailure0() throws {
        let session = Session(connectionService: ConnectionServiceMock())
        
        XCTAssertFalse(session.errorAlertIsPresenting)
        
        let expectation1 = publisherExpectation(
            session.$errorAlertIsPresenting.dropFirst(),
            equals: true
        )
        
        let expectedConnectionStatus: [ConnectionStatus] = [.undefined, .failure(ConnectionError.badAuthentication)]
        
        let expectation2 = publisherExpectation(
            session.$connectionStatus,
            equals: expectedConnectionStatus
        )
        
        session.updateConnectionStatus(.failure(ConnectionError.badAuthentication))
        
        wait(for: [expectation1, expectation2], timeout: 5)
        
        XCTAssertEqual(session.errorAlertMessage, "Bad authentication")
    }
    
    func testAlertAppear_WhenConnectionStatusIsUpdatedToFailure() throws {
        enum MergedValue: Equatable {
            case connectionStatus(ConnectionStatus)
            case errorAlertIsPresenting(Bool)
        }

        let session = Session(connectionService: ConnectionServiceMock())
        
//        XCTAssertFalse(session.errorAlertIsPresenting)
//        XCTAssertEqual(session.connectionStatus, .undefined)
//
//        let expectation = publisherExpectation(
//            session.$errorAlertIsPresenting.dropFirst().map(MergeValue.errorAlertIsPresenting)
//                .merge(with:
//                        session.$connectionStatus.dropFirst().map(MergeValue.connectionStatus)
//                      ),
//            equals: [
//                .connectionStatus(.failure(ConnectionError.badAuthentication)),
//                .errorAlertIsPresenting(true)
//            ]
//        )
        
//        let expectation = publisherExpectation(
//            session.$errorAlertIsPresenting.map(MergedValue.errorAlertIsPresenting)
//                .merge(with:
//                    session.$connectionStatus.map(MergedValue.connectionStatus)
//                )
//                .dropFirst(2), // dont test initial values
//            equals: [
//                .connectionStatus(.failure(ConnectionError.badAuthentication)),
//                .errorAlertIsPresenting(true)
//            ]
//        )

        let expectation = publisherExpectation(
            Publishers.Merge(
                session.$errorAlertIsPresenting.map(MergedValue.errorAlertIsPresenting),
                session.$connectionStatus.map(MergedValue.connectionStatus)
            )
            .dropFirst(2), // dont test initial values
            equals: [
                .connectionStatus(.failure(ConnectionError.badAuthentication)),
                .errorAlertIsPresenting(true)
            ]
        )

        session.updateConnectionStatus(.failure(ConnectionError.badAuthentication))
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(session.errorAlertMessage, "Bad authentication")
    }

    func testAlertAppear_WhenConnectionStatusIsUpdatedToFailure2() throws {
        enum Wrapped: Equatable {
            case connectionStatus(ConnectionStatus)
            case bool(Bool)
            
            init?<T: Equatable>(_ value: T)
            {
                switch value.self
                {
                case let v as ConnectionStatus:
                    self = .connectionStatus(v)
                case let v as Bool:
                    self = .bool(v)
                default:
                    return nil
                }
            }

        }

        let session = Session(connectionService: ConnectionServiceMock())
//        let p = session.$errorAlertIsPresenting.map(MergedValue.errorAlertIsPresenting).eraseToAnyPublisher()
//        let p = session.$errorAlertIsPresenting.eraseToAnyPublisher()

        let publisher =
//            session.$errorAlertIsPresenting.map(MergedValue.errorAlertIsPresenting)
//                .merge(with:
//                    session.$connectionStatus.map(MergedValue.connectionStatus)
//                )
            Publishers.Merge(
                session.$errorAlertIsPresenting.map(Wrapped.bool),
                session.$connectionStatus.map(Wrapped.connectionStatus)
            )
            .dropFirst(2) // dont test initial values
        
        let expectedValues: [Wrapped] = [
            .connectionStatus(.failure(ConnectionError.badAuthentication)),
            .bool(true)
        ]
        
        assertPublishedValues(publisher, equals: expectedValues) {
            session.updateConnectionStatus(.failure(ConnectionError.badAuthentication))
        }
                
        XCTAssertEqual(session.errorAlertMessage, "Bad authentication")
    }
}
