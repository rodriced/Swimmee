//
//  SwimmerSessionTests.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 13/12/2022.
//

import Foundation

import Combine
import XCTest

@testable import Swimmee

final class SwimmerSessionTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()

    private func newMockSwimmerSession(
        initialProfile: Profile,
        profileAPI: ProfileCommonAPI = MockProfileAPI(),
        workoutAPI: UserWorkoutCollectionAPI = MockUserWorkoutCollectionAPI(),
        messageAPI: UserMessageCollectionAPI = MockUserMessageCollectionAPI()
    ) -> SwimmerSession {
        SwimmerSession(initialProfile: initialProfile, profileAPI: profileAPI, workoutAPI: workoutAPI, messageAPI: messageAPI)
    }

    func testInit() {
        let aProfile = Samples.aProfile(of: .swimmer)
        let sut = newMockSwimmerSession(initialProfile: aProfile)

        XCTAssertEqual(sut.coachId, aProfile.coachId)
        XCTAssertEqual(sut.readWorkoutsIds, aProfile.readWorkoutsIds)
        XCTAssertEqual(sut.readMessagesIds, aProfile.readMessagesIds)
    }

    func testWorkoutsPublishers() {
        let aCoach = Samples.aCoachProfile

        var aWorkoutList = Samples.aWorkoutsList(userId: aCoach.userId)
        aWorkoutList[0].isSent = true
        aWorkoutList[1].isSent = true
        aWorkoutList[2].isSent = true

        var aSwimmer = Samples.aSwimmerProfile
        aSwimmer.coachId = aCoach.userId
        aSwimmer.readWorkoutsIds = [aWorkoutList[1].dbId!]

        let expectedUnreadWorkouts = 2

        let profileAPI = MockProfileAPI()
        profileAPI.mockPublisher = {
            Just(aSwimmer).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        let workoutAPI = MockUserWorkoutCollectionAPI()
        workoutAPI.mockListPublisher = {
            Just(aWorkoutList).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        let sut = newMockSwimmerSession(initialProfile: aSwimmer, profileAPI: profileAPI, workoutAPI: workoutAPI)

        sut.workoutsPublisher.drop { $0 != aWorkoutList }.sink(
            receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail()
                }
            },
            receiveValue: { XCTAssertEqual($0, aWorkoutList) }
        )
        .store(in: &cancellables)

        sut.readWorkoutsIdsPublisher.drop { $0 != aSwimmer.readWorkoutsIds }.sink(
            receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail()
                }
            },
            receiveValue: { XCTAssertEqual($0, aSwimmer.readWorkoutsIds) }
        )
        .store(in: &cancellables)

        sut.unreadWorkoutsCountPublisher.drop { $0 != expectedUnreadWorkouts }.sink(
            receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail()
                }
            },
            receiveValue: { XCTAssertEqual($0, expectedUnreadWorkouts) }
        )
        .store(in: &cancellables)

        sut.listenChanges()
    }

    func testMessagesPublishers() {
        let aCoach = Samples.aCoachProfile

        var aMessageList = Samples.aMessagesList(userId: aCoach.userId)
        aMessageList[0].isSent = true
        aMessageList[1].isSent = true
        aMessageList[2].isSent = true

        var aSwimmer = Samples.aSwimmerProfile
        aSwimmer.coachId = aCoach.userId
        aSwimmer.readMessagesIds = [aMessageList[1].dbId!]

        let expectedUnreadMessages = 2

        let profileAPI = MockProfileAPI()
        profileAPI.mockPublisher = {
            Just(aSwimmer).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        let messageAPI = MockUserMessageCollectionAPI()
        messageAPI.mockListPublisher = {
            Just(aMessageList).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        let sut = newMockSwimmerSession(initialProfile: aSwimmer, profileAPI: profileAPI, messageAPI: messageAPI)

        sut.messagesPublisher.drop { $0 != aMessageList }.sink(
            receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail()
                }
            },
            receiveValue: { XCTAssertEqual($0, aMessageList) }
        )
        .store(in: &cancellables)

        sut.readMessagesIdsPublisher.drop { $0 != aSwimmer.readMessagesIds }.sink(
            receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail()
                }
            },
            receiveValue: { XCTAssertEqual($0, aSwimmer.readMessagesIds) }
        )
        .store(in: &cancellables)

        sut.unreadMessagesCountPublisher.drop { $0 != expectedUnreadMessages }.sink(
            receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail()
                }
            },
            receiveValue: { XCTAssertEqual($0, expectedUnreadMessages) }
        )
        .store(in: &cancellables)

        sut.listenChanges()
    }
}
