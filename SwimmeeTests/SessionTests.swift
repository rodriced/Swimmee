//
//  SessionTests.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 07/11/2022.
//

import Combine
import XCTest

@testable import Swimmee

final class SessionTests: XCTestCase {
    static let mockAccountAPI = {
        let mock = MockAccountAPI()
        mock.mockSignOut = { true }
        return mock
    }()
    
    var cancellables = Set<AnyCancellable>()
    
    override func setUp() {
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
        
    func testAlertAppear_WhenAuthenticationStateIsUpdatedToFailure0() throws {
        let session = Session(accountAPI: Self.mockAccountAPI)
        
        XCTAssertFalse(session.errorAlertIsPresenting)
        
        let expectation1 = publisherExpectation(
            session.$errorAlertIsPresenting.print("$errorAlertIsPresenting").dropFirst(),
            equals: true, store: &cancellables
        )
        
        let expectedConnectionStatus: [AuthenticationState] = [.undefined, .failure(AccountError.authenticationFailure)]
        
        let expectation2 = publisherExpectation(
            session.$authenticationState,
            equals: expectedConnectionStatus, store: &cancellables
        )
        
        session.updateAuthenticationState(.failure(AccountError.authenticationFailure))
        
        wait(for: [expectation1, expectation2], timeout: 5)
        
        XCTAssertEqual(session.errorAlertMessage, "Authentication failure")
    }
    
    func testAlertAppear_WhenConnectionStatusIsUpdatedToFailure() throws {
        enum MergedValue: Equatable {
            case authenticationState(AuthenticationState)
            case errorAlertIsPresenting(Bool)
        }

        let session = Session(accountAPI: Self.mockAccountAPI)
        
//        XCTAssertFalse(session.errorAlertIsPresenting)
//        XCTAssertEqual(session.authenticationState, .undefined)
//
//        let expectation = publisherExpectation(
//            session.$errorAlertIsPresenting.dropFirst().map(MergeValue.errorAlertIsPresenting)
//                .merge(with:
//                        session.$authenticationState.dropFirst().map(MergeValue.authenticationState)
//                      ),
//            equals: [
//                .authenticationState(.failure(AccountError.authenticationFailure)),
//                .errorAlertIsPresenting(true)
//            ]
//        )
        
//        let expectation = publisherExpectation(
//            session.$errorAlertIsPresenting.map(MergedValue.errorAlertIsPresenting)
//                .merge(with:
//                    session.$authenticationState.map(MergedValue.authenticationState)
//                )
//                .dropFirst(2), // dont test initial values
//            equals: [
//                .authenticationState(.failure(AccountError.authenticationFailure)),
//                .errorAlertIsPresenting(true)
//            ]
//        )

        let expectation = publisherExpectation(
            Publishers.Merge(
                session.$errorAlertIsPresenting.map(MergedValue.errorAlertIsPresenting),
                session.$authenticationState.map(MergedValue.authenticationState)
            )
            .dropFirst(2), // dont test initial values
            equals: [
                .authenticationState(.failure(AccountError.authenticationFailure)),
                .errorAlertIsPresenting(true)
            ], store: &cancellables
        )

        session.updateAuthenticationState(.failure(AccountError.authenticationFailure))
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(session.errorAlertMessage, "Authentication failure")
    }

    func testAlertAppear_WhenConnectionStatusIsUpdatedToFailure2() throws {
        enum Wrapped: Equatable {
            case authenticationState(AuthenticationState)
            case bool(Bool)
            
            init?<T: Equatable>(_ value: T)
            {
                switch value.self
                {
                case let v as AuthenticationState:
                    self = .authenticationState(v)
                case let v as Bool:
                    self = .bool(v)
                default:
                    return nil
                }
            }

        }

        let session = Session(accountAPI: Self.mockAccountAPI)
//        let p = session.$errorAlertIsPresenting.map(MergedValue.errorAlertIsPresenting).eraseToAnyPublisher()
//        let p = session.$errorAlertIsPresenting.eraseToAnyPublisher()

        let publisher =
//            session.$errorAlertIsPresenting.map(MergedValue.errorAlertIsPresenting)
//                .merge(with:
//                    session.$authenticationState.map(MergedValue.authenticationState)
//                )
            Publishers.Merge(
                session.$errorAlertIsPresenting.map(Wrapped.bool),
                session.$authenticationState.map(Wrapped.authenticationState)
            )
            .dropFirst(2) // dont test initial values
        
        let expectedValues: [Wrapped] = [
            .authenticationState(.failure(AccountError.authenticationFailure)),
            .bool(true)
        ]
        
        assertPublishedValues(publisher, equals: expectedValues, store: &cancellables) {
            session.updateAuthenticationState(.failure(AccountError.authenticationFailure))
        }
                
        XCTAssertEqual(session.errorAlertMessage, "Authentication failure")
    }
}
