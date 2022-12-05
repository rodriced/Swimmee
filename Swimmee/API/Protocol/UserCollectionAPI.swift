//
//  CollectionAPI.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 05/12/2022.
//

import Combine
import Foundation

protocol DbIdentifiable: Codable {
    var dbId: String? { get set }
}

enum OwnerFilter {
    case currentUser
    case user(UserId)
    case any
}

protocol UserMessageCollectionAPI {
    func listPublisher(owner: OwnerFilter, isSent: Bool?) -> AnyPublisher<[Message], Error>
    func save(_ item: Message, replaceAsNew: Bool) async throws -> String
    func delete(id: String) async throws
}
