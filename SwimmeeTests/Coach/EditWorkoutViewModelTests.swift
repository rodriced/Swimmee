//
//  EditWorkoutViewModelTests.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 19/12/2022.
//

@testable import Swimmee

import XCTest

final class EditWorkoutViewModelTests: XCTestCase {
    func testNotSentWorkoutValidation() {
        let workoutAPI = MockUserWorkoutCollectionAPI()
        //        let aWorkout = Samples.aWorkout(userId: Samples.aUserId)
        
        let aWorkout = Workout(userId: Samples.aUserId, title: "A Title", content: "A content", isSent: false)
        
        let sut = EditWorkoutViewModel(workout: aWorkout, workoutAPI: workoutAPI)
        XCTAssertEqual(sut.validateTitle(), true)
        XCTAssertEqual(sut.canTryToSend, true)
        XCTAssertEqual(sut.canTryToSaveAsDraft, false)
        
        sut.workout.title = "      " // Some spaces
        XCTAssertEqual(sut.validateTitle(), false)
        XCTAssertEqual(sut.canTryToSend, true)
        XCTAssertEqual(sut.canTryToSaveAsDraft, true)
        
        sut.workout.title = "  A Title  "
        XCTAssertEqual(sut.validateTitle(), true)
        XCTAssertEqual(sut.canTryToSend, true)
        XCTAssertEqual(sut.canTryToSaveAsDraft, true)
    }
    
    func testSentWorkoutValidation() {
        let workoutAPI = MockUserWorkoutCollectionAPI()
        //        let aWorkout = Samples.aWorkout(userId: Samples.aUserId)
        
        let aWorkout = Workout(userId: Samples.aUserId, title: "A Title", content: "A content", isSent: true)
        
        let sut = EditWorkoutViewModel(workout: aWorkout, workoutAPI: workoutAPI)
        XCTAssertEqual(sut.validateTitle(), true)
        XCTAssertEqual(sut.canTryToSend, false)
        XCTAssertEqual(sut.canTryToSaveAsDraft, true)
        
        sut.workout.title = "      " // Some spaces
        XCTAssertEqual(sut.validateTitle(), false)
        XCTAssertEqual(sut.canTryToSend, true)
        XCTAssertEqual(sut.canTryToSaveAsDraft, true)
        
        sut.workout.title = "  A Title  "
        XCTAssertEqual(sut.validateTitle(), true)
        XCTAssertEqual(sut.canTryToSend, true)
        XCTAssertEqual(sut.canTryToSaveAsDraft, true)
    }
    
    func testSaveAsDraftUnsentWorkout() {
        let aWorkout = Samples.aWorkout(userId: Samples.aUserId, isSent: false)
        let newContent = "New cntent"
        //        let expectedSavedWorkout = aWorkout
        let expectedSavedWorkout = {
            var workout = aWorkout
            workout.content = newContent
            return workout
        }()
        
        let workoutAPI = MockUserWorkoutCollectionAPI()
        workoutAPI.mockSave = { workoutToSave, replaceAsNew in
            XCTAssertEqual(workoutToSave, expectedSavedWorkout)
            XCTAssertEqual(replaceAsNew, false)
            return expectedSavedWorkout.userId
        }
        let sut = EditWorkoutViewModel(workout: aWorkout, workoutAPI: workoutAPI)
        
        sut.workout.content = newContent
        
        sut.saveWorkout(andSendIt: false, onValidationError: { XCTFail() })
    }
    
    func testSendUnsentWorkout() {
        let aWorkout = Samples.aWorkout(userId: Samples.aUserId, isSent: false)
        var expectedSavedWorkout = {
            var workout = aWorkout
            workout.isSent = true
            return workout
        }()
        
        let workoutAPI = MockUserWorkoutCollectionAPI()
        workoutAPI.mockSave = { workoutToSave, replaceAsNew in
            XCTAssertNotEqual(workoutToSave.date, expectedSavedWorkout.date)
            expectedSavedWorkout.date = workoutToSave.date
            
            XCTAssertEqual(workoutToSave, expectedSavedWorkout)
            XCTAssertEqual(replaceAsNew, true)
            return expectedSavedWorkout.userId
        }
        let sut = EditWorkoutViewModel(workout: aWorkout, workoutAPI: workoutAPI)
                
        sut.saveWorkout(andSendIt: true, onValidationError: { XCTFail() })
    }
    
    func testSaveAsDraftSentWorkout() {
        let aWorkout = Samples.aWorkout(userId: Samples.aUserId, isSent: true)
        let expectedSavedWorkout = {
            var workout = aWorkout
            workout.isSent = false
            return workout
        }()
        
        let workoutAPI = MockUserWorkoutCollectionAPI()
        workoutAPI.mockSave = { workoutToSave, replaceAsNew in
//            expectedSavedWorkout.date = workoutToSave.date
            XCTAssertEqual(workoutToSave, expectedSavedWorkout)
            XCTAssertEqual(replaceAsNew, false)
            return expectedSavedWorkout.userId
        }
        let sut = EditWorkoutViewModel(workout: aWorkout, workoutAPI: workoutAPI)
                
        sut.saveWorkout(andSendIt: false, onValidationError: { XCTFail() })
    }
    
    func testReplaceSentWorkout() {
        let aWorkout = Samples.aWorkout(userId: Samples.aUserId, isSent: true)
        var expectedSavedWorkout = aWorkout
                
        let workoutAPI = MockUserWorkoutCollectionAPI()
        workoutAPI.mockSave = { workoutToSave, replaceAsNew in
            XCTAssertNotEqual(workoutToSave.date, expectedSavedWorkout.date)
            expectedSavedWorkout.date = workoutToSave.date
            
            XCTAssertEqual(workoutToSave, expectedSavedWorkout)
            XCTAssertEqual(replaceAsNew, true)
            return expectedSavedWorkout.userId
        }
        let sut = EditWorkoutViewModel(workout: aWorkout, workoutAPI: workoutAPI)
                
        sut.saveWorkout(andSendIt: true, onValidationError: { XCTFail() })
    }
    
    func testSaveWorkoutWithValidationError() {
        let aWorkout = Samples.aWorkout(userId: Samples.aUserId, isSent: false)
        
        let workoutAPI = MockUserWorkoutCollectionAPI()
        let sut = EditWorkoutViewModel(workout: aWorkout, workoutAPI: workoutAPI)
        sut.workout.title = ""
        
        let expectation = expectation(description: "Waiting for onError")
        
        assertPublishedValue(sut.alertContext.$isPresented, equals: true) {
            sut.saveWorkout(andSendIt: false, onValidationError: { expectation.fulfill() })
        }
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssertEqual(sut.alertContext.message, "Put something in title and retry.")
    }
    
    func testSaveWorkoutWithNetworkError() {
        let aWorkout = Samples.aWorkout(userId: Samples.aUserId, isSent: false)
        
        let workoutAPI = MockUserWorkoutCollectionAPI()
        workoutAPI.mockSave = { _, _ in
            throw TestError.fakeNetworkError
        }
        let sut = EditWorkoutViewModel(workout: aWorkout, workoutAPI: workoutAPI)
        sut.workout.content = "New cntent"
                
        assertPublishedValue(sut.alertContext.$isPresented, equals: true) {
            sut.saveWorkout(andSendIt: false, onValidationError: { XCTFail() })
        }
                
        XCTAssertEqual(sut.alertContext.message, "fakeNetworkError")
    }
    
    func testDeleteWorkout() {
        let aWorkout = Samples.aWorkout(userId: Samples.aUserId, isSent: false)
        let expectedDeletedWorkout = aWorkout
        
        let workoutAPI = MockUserWorkoutCollectionAPI()
        workoutAPI.mockDelete = { workoutToSaveUserId in
            XCTAssertEqual(workoutToSaveUserId, expectedDeletedWorkout.dbId)
        }
        let sut = EditWorkoutViewModel(workout: aWorkout, workoutAPI: workoutAPI)
                
        let expectation = expectation(description: "Waiting for completion")
        sut.deleteWorkout(completion: { expectation.fulfill() })
        
        wait(for: [expectation], timeout: 1)
    }

    func testDeleteWorkoutWithNetworkError() {
        let aWorkout = Samples.aWorkout(userId: Samples.aUserId, isSent: false)
        
        let workoutAPI = MockUserWorkoutCollectionAPI()
        workoutAPI.mockDelete = { _ in
            throw TestError.fakeNetworkError
        }
        let sut = EditWorkoutViewModel(workout: aWorkout, workoutAPI: workoutAPI)
        
        assertPublishedValue(sut.alertContext.$isPresented, equals: true) {
            sut.deleteWorkout(completion: { XCTFail() })
        }
        
        XCTAssertEqual(sut.alertContext.message, "fakeNetworkError")
    }
}
