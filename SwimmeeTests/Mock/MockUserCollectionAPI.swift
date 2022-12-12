//
//  MockUserCollectionAPI.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 12/12/2022.
//

@testable import Swimmee

import Combine

class FirestoreUserWorkoutCollectionAPI: MockUserCollectionAPI<Workout>, UserWorkoutCollectionAPI {}
class FirestoreUserMessageCollectionAPI: MockUserCollectionAPI<Message>, UserMessageCollectionAPI {}

class MockUserCollectionAPI<Item: DbIdentifiable> {
    var mockListPublisher: () -> AnyPublisher<[Item], Error> = { BadContextCallInMockFail(); fatalError() }
    var mockSave: () async throws -> String = { BadContextCallInMockFail(); fatalError() }
    var mockDelete: () async throws -> Void = { BadContextCallInMockFail(); fatalError() }
    
    func listPublisher(owner: OwnerFilter = .currentUser, isSent: Bool? = nil) -> AnyPublisher<[Item], Error> {
        mockListPublisher()
    }
    
    func save(_ item: Item, replaceAsNew: Bool = false) async throws -> String {
        try await mockSave()
    }

    func delete(id: String) async throws {
        try await mockDelete()
    }
}
