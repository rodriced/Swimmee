//
//  CollectionAPI.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 05/12/2022.
//

import Foundation
import Combine

protocol DbIdentifiable: Codable {
    var dbId: String? { get set }
}

enum OwnerFilter {
    case currentUser
    case user(UserId)
    case any
}

protocol UserCollectionAPI {
    associatedtype Item: DbIdentifiable
    
    func listPublisher(owner: OwnerFilter, isSent: Bool?) -> AnyPublisher<[Item], Error>
    func save(_ item: Item, replaceAsNew: Bool) async throws -> String
    func delete(id: String) async throws
}
