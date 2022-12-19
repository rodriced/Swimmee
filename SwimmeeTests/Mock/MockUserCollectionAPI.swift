//
//  MockUserCollectionAPI.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 12/12/2022.
//

@testable import Swimmee

import Combine

class MockUserWorkoutCollectionAPI: MockUserCollectionAPI<Workout>, UserWorkoutCollectionAPI {}
class MockUserMessageCollectionAPI: MockUserCollectionAPI<Message>, UserMessageCollectionAPI {}

class MockUserCollectionAPI<Item: DbIdentifiable> {
    var mockListPublisher: () -> AnyPublisher<[Item], Error> = { BadContextCallInMockFail(); fatalError() }
    var mockSave: (Item, Bool) async throws -> String = {_, _ in BadContextCallInMockFail(); fatalError() }
    var mockDelete: (String) async throws -> Void = { _ in BadContextCallInMockFail(); fatalError() }
    
    func listPublisher(owner: OwnerFilter = .currentUser, isSent: Bool? = nil) -> AnyPublisher<[Item], Error> {
        mockListPublisher()
    }
    
    func save(_ item: Item, replaceAsNew: Bool = false) async throws -> String {
        try await mockSave(item, replaceAsNew)
    }

    func delete(id: String) async throws {
        try await mockDelete(id)
    }
}
