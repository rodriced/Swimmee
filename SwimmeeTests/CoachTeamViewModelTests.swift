//
//  CoachTeamViewModelTests.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 11/12/2022.
//

@testable import Swimmee

import Foundation
import XCTest

final class CoachTeamViewModelTests: XCTestCase {
    func testNormalTeamWorkflow() {
        let aTeam = Samples.aTeam

        let profileAPI = MockProfilePI()
        profileAPI.mockLoadTeam = {
//            await withCheckedContinuation { continuation in
//                DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(2))) {
//                    continuation.resume(returning: aTeam)
//                }
//            }
            aTeam
        }

        let sut = CoachTeamViewModel(profileAPI: profileAPI)

        XCTAssertEqual(sut.state, .loading)

//        assertPublishedValues(
//            sut.$state,
//            equals: [.loading, .normal(aTeam)])
        assertPublishedValue(
            sut.$state,
            equals: .normal(aTeam)
        ) {
            Task {
                await sut.loadTeam()
            }
        }

//        let expectation = publisherExpectation(
//            sut.$state,
//            equals: [.loading, .normal(Samples.aTeam)])
//
//        Task {
//            await sut.loadTeam()
//        }
    }

    func testEmptyTeamWorkflow() {
        let anEmptyTeam: [Profile] = []

        let profileAPI = MockProfilePI()
        profileAPI.mockLoadTeam = { anEmptyTeam }

        let sut = CoachTeamViewModel(profileAPI: profileAPI)

        XCTAssertEqual(sut.state, .loading)

        assertPublishedValue(
            sut.$state,
            equals: .info("No swimmers in your team for now.")
        ) {
            Task {
                await sut.loadTeam()
            }
        }
    }

    func testNetworkErrorWorkflow() {
        let profileAPI = MockProfilePI()
        profileAPI.mockLoadTeam = { throw TestError.fakeNetworkError }

        let sut = CoachTeamViewModel(profileAPI: profileAPI)

        XCTAssertEqual(sut.state, .loading)

        assertPublishedValue(
            sut.$state,
            equals: .info("fakeNetworkError")
        ) {
            Task {
                await sut.loadTeam()
            }
        }
    }
}
