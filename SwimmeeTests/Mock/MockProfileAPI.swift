//
//  MockProfileAPI.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 11/12/2022.
//

@testable import Swimmee

import Foundation
import Combine

class MockProfilePI: ProfileAPI {
    var mockFuture: () -> AnyPublisher<Profile, Error> = { BadContextCallInMockFail(); fatalError() }
    var mockPublisher: () -> AnyPublisher<Profile, Error> = { BadContextCallInMockFail(); fatalError() }
    var mockLoad: () async throws -> Profile = { BadContextCallInMockFail(); fatalError() }
    var mockSave: () async throws -> Void = { BadContextCallInMockFail(); fatalError() }

    var mockLoadTeam: () async throws -> [Profile] = { BadContextCallInMockFail(); fatalError() }

    var mockLoadCoachs: () async throws -> [Profile] = { BadContextCallInMockFail(); fatalError() }
    var mockUpdateCoach: () async throws -> Void = { BadContextCallInMockFail(); fatalError() }
    var mockSetWorkoutAsRead: (_ workoutDbId: Workout.DbId) async throws -> Void = {_ in BadContextCallInMockFail(); fatalError() }
    var mockSetMessageAsRead: (_ messageDbId: Message.DbId) async throws -> Void = { _ in BadContextCallInMockFail(); fatalError() }

    var mockDelete: () async throws -> Void = { BadContextCallInMockFail(); fatalError() }

    
    func future(userId: String?) -> AnyPublisher<Profile, Error> {
        mockFuture()
    }
    func publisher(userId: String?) -> AnyPublisher<Profile, Error> {
        mockPublisher()
    }
    func load(userId: String) async throws -> Profile {
        try await mockLoad()
    }
    func save(_ profile: Profile) async throws {
        try await mockSave()
    }

    func loadTeam() async throws -> [Profile] {
        try await mockLoadTeam()
    }

    func loadCoachs() async throws -> [Profile] {
        try await mockLoadCoachs()
    }
    func updateCoach(with coachId: String?) async throws {
        try await mockUpdateCoach()
    }
    func setWorkoutAsRead(_ workoutDbId: Workout.DbId) async throws {
        try await mockSetWorkoutAsRead(workoutDbId)
    }
    func setMessageAsRead(_ messageDbId: Message.DbId) async throws {
        try await mockSetMessageAsRead(messageDbId)
    }

    func delete(userId: String) async throws {
        try await mockDelete()
    }
}
