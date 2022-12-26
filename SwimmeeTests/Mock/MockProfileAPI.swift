//
//  MockProfileAPI.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 11/12/2022.
//

@testable import Swimmee

import Combine
import Foundation

class MockProfileAPI: ProfileAPI {
    var mockFuture: () -> AnyPublisher<Profile, Error> = { MockFunctionNotInitialized(); fatalError() }
    var mockPublisher: () -> AnyPublisher<Profile, Error> = { MockFunctionNotInitialized(); fatalError() }
    var mockLoad: () async throws -> Profile = { MockFunctionNotInitialized(); fatalError() }
    var mockSave: (Profile) async throws -> Void = { _ in MockFunctionNotInitialized(); fatalError() }

    var mockLoadTeam: () async throws -> [Profile] = { MockFunctionNotInitialized(); fatalError() }

    var mockLoadCoachs: () async throws -> [Profile] = { MockFunctionNotInitialized(); fatalError() }
    var mockUpdateCoach: () async throws -> Void = { MockFunctionNotInitialized(); fatalError() }
    var mockSetWorkoutAsRead: (_ workoutDbId: Workout.DbId) async throws -> Void = { _ in MockFunctionNotInitialized(); fatalError() }
    var mockSetMessageAsRead: (_ messageDbId: Message.DbId) async throws -> Void = { _ in MockFunctionNotInitialized(); fatalError() }

    var mockDelete: () async throws -> Void = { MockFunctionNotInitialized(); fatalError() }

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
        try await mockSave(profile)
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
