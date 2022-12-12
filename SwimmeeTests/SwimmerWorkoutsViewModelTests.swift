//
//  SwimmerWorkoutsViewModelTests.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 12/12/2022.
//

@testable import Swimmee

import Combine
import XCTest

final class SwimmerWorkoutsViewModelTests: XCTestCase {
    func testLoading() throws {
        let aWorkoutsList = Samples.aWorkoutsList(userId: "COACH_ID")
        let readWorkoutsIds = Set(aWorkoutsList[1 ... 2].map { $0.dbId! })

        let expectedWorkoutsParams = aWorkoutsList.map { (workout: $0, isRead: readWorkoutsIds.contains($0.dbId!)) }

        let profileAPI = MockProfilePI()
        let config = SwimmerWorkoutsViewModel.Config(profileAPI: profileAPI)

        let sut = SwimmerWorkoutsViewModel(initialData: (aWorkoutsList, Set(readWorkoutsIds)), config: config)

        for (workoutParams, expectedWorkoutParams) in zip(sut.workoutsParams, expectedWorkoutsParams) {
            XCTAssertEqual(workoutParams.workout, expectedWorkoutParams.workout)
            XCTAssertEqual(workoutParams.isRead, expectedWorkoutParams.isRead)
        }

        XCTAssertEqual(sut.newWorkoutsCount, aWorkoutsList.count - readWorkoutsIds.count)
    }

    func testSuccessfullSetWorkoutAsRead() {
        let aWorkoutsList = Samples.aWorkoutsList(userId: "COACH_ID")

        let profileAPI = MockProfilePI()
        profileAPI.mockSetWorkoutAsRead = { dbId in
            XCTAssertEqual(dbId, aWorkoutsList[0].dbId!)
        }

        let config = SwimmerWorkoutsViewModel.Config(profileAPI: profileAPI)
        let sut = SwimmerWorkoutsViewModel(initialData: (aWorkoutsList, []), config: config)

        sut.setWorkoutAsRead(sut.workoutsParams[0].workout)
    }
}
