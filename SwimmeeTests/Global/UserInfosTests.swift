//
//  UserInfosTests.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 13/12/2022.
//

import Foundation

import Combine
import XCTest

@testable import Swimmee

final class UserInfosTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()

    private func newMockUserInfosTests(
        profile: Profile,
        profileAPI: ProfileCommonAPI = MockProfilePI()
    ) -> UserInfos {
        UserInfos(profile: profile, profileAPI: profileAPI)
    }

    func testInit() {
        let aProfile = Samples.aProfile(of: .coach)
        let sut = newMockUserInfosTests(profile: aProfile)

        XCTAssertEqual(sut.userId, aProfile.userId)
        XCTAssertEqual(sut.userType, .coach)
    }
}
