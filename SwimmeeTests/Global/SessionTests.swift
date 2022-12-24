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
    func testAlertAppear_WhenAuthenticationStateIsUpdatedToFailure0() throws {
        let session = Session(accountAPI: MockAccountAPI())
        
        XCTAssertFalse(session.authenticationFailureAlert.isPresented)
        
        let expectation1 = publisherExpectation(
            session.authenticationFailureAlert.$isPresented.print("$errorAlertIsPresenting").dropFirst(),
            equals: true
        )
        
        let expectedConnectionStatus: [AuthenticationState] = [.undefined, .failure(AccountError.authenticationFailure)]
        
        let expectation2 = publisherExpectation(
            session.$authenticationState,
            equals: expectedConnectionStatus
        )
        
        session.updateAuthenticationState(.failure(AccountError.authenticationFailure))
        
        wait(for: [expectation1, expectation2], timeout: 5)
        
        XCTAssertEqual(session.authenticationFailureAlert.message, "Authentication failure")
    }
    
    func testAlertAppear_WhenConnectionStatusIsUpdatedToFailure() throws {
        enum MergedValue: Equatable {
            case authenticationState(AuthenticationState)
            case errorAlertIsPresenting(Bool)
        }

        let session = Session(accountAPI: MockAccountAPI())
        
        let expectation = publisherExpectation(
            Publishers.Merge(
                session.authenticationFailureAlert.$isPresented.map(MergedValue.errorAlertIsPresenting),
                session.$authenticationState.map(MergedValue.authenticationState)
            )
            .dropFirst(2), // dont test initial values
            equals: [
                .authenticationState(.failure(AccountError.authenticationFailure)),
                .errorAlertIsPresenting(true)
            ]
        )

        session.updateAuthenticationState(.failure(AccountError.authenticationFailure))
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(session.authenticationFailureAlert.message, "Authentication failure")
    }

    func testAlertAppear_WhenConnectionStatusIsUpdatedToFailure2() throws {
        enum Wrapped: Equatable {
            case authenticationState(AuthenticationState)
            case bool(Bool)
            
            init?<T: Equatable>(_ value: T) {
                switch value.self {
                case let v as AuthenticationState:
                    self = .authenticationState(v)
                case let v as Bool:
                    self = .bool(v)
                default:
                    return nil
                }
            }
        }

        let session = Session(accountAPI: MockAccountAPI())

        let publisher =
            Publishers.Merge(
                session.authenticationFailureAlert.$isPresented.map(Wrapped.bool),
                session.$authenticationState.map(Wrapped.authenticationState)
            )
            .dropFirst(2) // dont test initial values
        
        let expectedValues: [Wrapped] = [
            .authenticationState(.failure(AccountError.authenticationFailure)),
            .bool(true)
        ]
        
        assertPublishedValues(publisher, equals: expectedValues) {
            session.updateAuthenticationState(.failure(AccountError.authenticationFailure))
        }
                
        XCTAssertEqual(session.authenticationFailureAlert.message, "Authentication failure")
    }
}
