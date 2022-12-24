//
//  WorkoutTagsTests.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 11/12/2022.
//

@testable import Swimmee

import XCTest

final class WorkoutTagsTests: XCTestCase {
    let freestyleIndex = Workout.allTags.firstIndex(of: "freestyle")
    let dolphinKickIndex = Workout.allTags.firstIndex(of: "dolphin kick")

    func aWorkoutWith(title: String, content: String) -> Workout {
        Workout(userId: "", title: title, content: content)
    }

    func testUpdateTagsCacheForOneWorkout() throws {
        var workout: Workout
        
        workout = aWorkoutWith(title: "  dsaasd ", content: "fsflksjdfl")
        Workout.updateTagsCache(for: &workout)
        
        XCTAssertEqual(workout.tagsCache, [])
        
        workout = aWorkoutWith(title: "  Freestyle ", content: "fsflksjdfl")
        Workout.updateTagsCache(for: &workout)
        
        XCTAssertEqual(workout.tagsCache, [freestyleIndex])
        
        workout = aWorkoutWith(title: "Workout #23", content: "fdfjkj freestyle jkfjdkjf\nfjdls")
        Workout.updateTagsCache(for: &workout)
        
        XCTAssertEqual(workout.tagsCache, [freestyleIndex])
    }
    
    func testUpdateTagsCacheForAWorkoutsList() throws {
        var workouts = [
            aWorkoutWith(title: "  dsaasd ", content: "fsflksjdfl"),
            aWorkoutWith(title: "  Freestyle ", content: "fsflksjdfl dolphin kick jdk"),
            aWorkoutWith(title: "AAAAA AAA", content: " kkl dolphin  kIck  fkjdls \n ffsjfl \n jkjkfds"),
            aWorkoutWith(title: "Workout #23", content: "fdfjkj freestyle jkfjdkjf\nfjdls"),
        ]
        
        let expectedTagsCaches = [
            [],
            [freestyleIndex, dolphinKickIndex],
            [dolphinKickIndex],
            [freestyleIndex],
        ].map(Set.init)
        
        Workout.updateTagsCache(for: &workouts)

        for (workout, expectedTagsCache) in zip(workouts, expectedTagsCaches) {
            XCTAssertEqual(workout.tagsCache, expectedTagsCache)
        }
    }
}
