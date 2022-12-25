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

        let profileAPI = MockProfileAPI()
        profileAPI.mockLoadTeam = {
            aTeam
        }

        let sut = CoachTeamViewModel(profileAPI: profileAPI)

        XCTAssertEqual(sut.state, .loading)

        assertPublishedValue(
            sut.$state,
            equals: .normal(aTeam)
        ) {
            Task {
                await sut.loadTeam()
            }
        }
    }

    func testEmptyTeamWorkflow() {
        let anEmptyTeam: [Profile] = []

        let profileAPI = MockProfileAPI()
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
        let profileAPI = MockProfileAPI()
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
