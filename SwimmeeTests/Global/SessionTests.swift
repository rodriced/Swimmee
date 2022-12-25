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
        let currentUserIdPublisher: CurrentValueSubject<UserId?, Never> = CurrentValueSubject(UserId?.none)

        let accountAPI = MockAccountAPI()
        accountAPI.mockCurrentUserIdPublisher = {
            currentUserIdPublisher.eraseToAnyPublisher()
        }
        let profileAPI = MockProfileAPI()
        profileAPI.mockFuture = {
            Fail(outputType: Profile.self, failure: AccountError.profileLoadingError)
                .eraseToAnyPublisher()
        }
        let session = Session(accountAPI: accountAPI, profileAPI: profileAPI)

        XCTAssertEqual(session.state, .undefined)
        XCTAssertEqual(session.stateFailureAlert.isPresented, false)

        let expectation1 = publisherExpectation(
            session.stateFailureAlert.$isPresented.print("$errorAlertIsPresenting"),
            equals: true
        )

        let expectedConnectionStatus: [SessionState] = [.undefined, .signedOut, .failure(AccountError.profileLoadingError)]

        let expectation2 = publisherExpectation(
            session.$state.print("session.$sate"),
            equals: expectedConnectionStatus
//            equals: .failure(AccountError.authenticationFailure)
        )

        session.startStateWorkflow()
        currentUserIdPublisher.send(Samples.aCoachUserId)

        wait(for: [expectation1, expectation2], timeout: 5)

        XCTAssertEqual(session.stateFailureAlert.message, "User profile could not be loaded.")
    }
}
