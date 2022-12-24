//
//  WorkoutTests.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 15/12/2022.
//

@testable import Swimmee

import XCTest

final class WorkoutTests: XCTestCase {
    func testIsNew() {
        var aWorkout = Samples.aWorkout(userId: Samples.aUserId)

        aWorkout.dbId = nil
        XCTAssertEqual(aWorkout.isNew, true)

        aWorkout.dbId = Samples.aRandomDbId
        XCTAssertEqual(aWorkout.isNew, false)
    }

    func testHasTextDifferent() {
        let workout1 = Workout(userId: Samples.aUserId(ref: 1), title: "A Title", content: "A content")
        let workout2 = Workout(userId: Samples.aUserId(ref: 2), title: "Another Title", content: "A content")
        let workout3 = Workout(userId: Samples.aUserId(ref: 3), title: "A Title", content: "Another content")
        let workout4 = Workout(userId: Samples.aUserId(ref: 4), title: "Another Title", content: "Another content")

        XCTAssertEqual(workout1.hasTextDifferent(from: workout1), false)
        XCTAssertEqual(workout1.hasTextDifferent(from: workout2), true)
        XCTAssertEqual(workout1.hasTextDifferent(from: workout3), true)
        XCTAssertEqual(workout1.hasTextDifferent(from: workout4), true)
    }
}
