//
//  CoachWorkoutsViewModelTests.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 12/12/2022.
//

@testable import Swimmee

import Combine
import XCTest

final class CoachWorkoutsViewModelTests: XCTestCase {
    func testLoadingWithoutAndWithFilter() throws {
        var aWorkoutsList = Samples.aWorkoutsList(userId: "COACH_ID")
        aWorkoutsList[1].isSent = true
        aWorkoutsList[2].isSent = true

        let expectedDraftWorkouts = aWorkoutsList.filter { !$0.isSent }
        let expectedSentWorkouts = aWorkoutsList.filter { $0.isSent }

        let workoutAPI = MockUserWorkoutCollectionAPI()
        let config = CoachWorkoutsViewModel.Config(workoutAPI: workoutAPI)

        let sut = CoachWorkoutsViewModel(initialData: aWorkoutsList, config: config)

        XCTAssertEqual(sut.tagFilterSelection, nil)
        XCTAssertEqual(sut.statusFilterSelection, .all)
        
        XCTAssertEqual(sut.workouts, aWorkoutsList)
        XCTAssertEqual(sut.filteredWorkouts, aWorkoutsList)

        sut.statusFilterSelection = .draft

        XCTAssertEqual(sut.workouts, aWorkoutsList)
        XCTAssertEqual(sut.filteredWorkouts, expectedDraftWorkouts)
        
        sut.statusFilterSelection = .sent

        XCTAssertEqual(sut.workouts, aWorkoutsList)
        XCTAssertEqual(sut.filteredWorkouts, expectedSentWorkouts)
        
        sut.clearFilters()
        
        XCTAssertEqual(sut.tagFilterSelection, nil)
        XCTAssertEqual(sut.statusFilterSelection, .all)
        XCTAssertEqual(sut.filteredWorkouts, aWorkoutsList)
    }

    func testGoEditingWorkout() {
        let aWorkoutsList = Samples.aWorkoutsList(userId: "COACH_ID")
        var aWorkout = aWorkoutsList[0]

        let workoutAPI = MockUserWorkoutCollectionAPI()
        let config = CoachWorkoutsViewModel.Config(workoutAPI: workoutAPI)

        let sut = CoachWorkoutsViewModel(initialData: aWorkoutsList, config: config)

        XCTAssertEqual(sut.selectedWorkout, nil)
        XCTAssertFalse(sut.sentWorkoutEditionConfirmationDialogPresented)
        XCTAssertFalse(sut.navigatingToEditView)
        
        aWorkout.isSent = false
        sut.goEditingWorkout(aWorkout)

        XCTAssertEqual(sut.selectedWorkout, aWorkout)
        XCTAssertFalse(sut.sentWorkoutEditionConfirmationDialogPresented)
        XCTAssertTrue(sut.navigatingToEditView)

        aWorkout.isSent = true
        sut.goEditingWorkout(aWorkout)

        XCTAssertEqual(sut.selectedWorkout, aWorkout)
        XCTAssertTrue(sut.sentWorkoutEditionConfirmationDialogPresented)
        XCTAssertFalse(sut.navigatingToEditView)
    }

    func testSuccessfullDeleteWorkout() {
        let aWorkoutsList = Samples.aWorkoutsList(userId: "COACH_ID")
        let aWorkout = aWorkoutsList[1]

        var expectedUpdatedWorkoutsList = aWorkoutsList
        expectedUpdatedWorkoutsList.remove(at: 1)

        let workoutAPI = MockUserWorkoutCollectionAPI()
        workoutAPI.mockDelete = { workoutDbId in
            XCTAssertEqual(workoutDbId, aWorkout.dbId!)
        }
        let config = CoachWorkoutsViewModel.Config(workoutAPI: workoutAPI)

        let sut = CoachWorkoutsViewModel(initialData: aWorkoutsList, config: config)

        assertPublishedValue(
            sut.$workouts,
            equals: expectedUpdatedWorkoutsList
        ) {
            sut.deleteWorkout(at: IndexSet(integer: 1))
        }
    }

    func testDeleteWorkoutWithError() {
        let aWorkoutsList = Samples.aWorkoutsList(userId: "COACH_ID")

        let workoutAPI = MockUserWorkoutCollectionAPI()
        workoutAPI.mockDelete = { _ in
            throw TestError.fakeNetworkError
        }
        let config = CoachWorkoutsViewModel.Config(workoutAPI: workoutAPI)

        let sut = CoachWorkoutsViewModel(initialData: aWorkoutsList, config: config)

        XCTAssertFalse(sut.alertContext.isPresented)
        
        assertPublishedValue(
            sut.alertContext.$isPresented,
            equals: true
        ) {
            sut.deleteWorkout(at: IndexSet(integer: 1))
        }
        
        XCTAssertEqual(sut.alertContext.message, "fakeNetworkError")
    }
}
