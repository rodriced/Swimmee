//
//  CoachSessionTests.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 13/12/2022.
//

import Foundation

import Combine
import XCTest

@testable import Swimmee

final class CoachSessionTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()
    
    private func newMockCoachSession(
        workoutAPI: UserWorkoutCollectionAPI = MockUserWorkoutCollectionAPI(),
        messageAPI: UserMessageCollectionAPI = MockUserMessageCollectionAPI()
    ) -> CoachSession {
        CoachSession(workoutAPI: workoutAPI, messageAPI: messageAPI)
    }
    
    
    func testWorkoutsPublisher() {
        let aProfile = Samples.aProfile(of: .coach)
        let aWorkoutList = Samples.aWorkoutsList(userId: aProfile.userId)
        
        let workoutAPI = MockUserWorkoutCollectionAPI()
        workoutAPI.mockListPublisher = {
            Just(aWorkoutList).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        
        let sut = newMockCoachSession(workoutAPI: workoutAPI)
        
        sut.workoutsPublisher.sink(
            receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail()
                }
            },
            receiveValue: { XCTAssertEqual($0, aWorkoutList) }
        )
        .store(in: &cancellables)
    }
    
    func testMessagesPublisher() {
        let aProfile = Samples.aProfile(of: .coach)
        let aMessagesList = Samples.aMessagesList(userId: aProfile.userId)

        let messageAPI = MockUserMessageCollectionAPI()
        messageAPI.mockListPublisher = {
            Just(aMessagesList).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        let sut = newMockCoachSession(messageAPI: messageAPI)

        sut.messagesPublisher.sink(
            receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail()
                }
            },
            receiveValue: { XCTAssertEqual($0, aMessagesList) }
        )
        .store(in: &cancellables)
    }

}
