//
//  FirestoreUserCollectionAPI.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 30/10/2022.
//

import Combine
import FirebaseFirestore
import FirebaseFirestoreCombineSwift
import FirebaseFirestoreSwift
import Foundation

class FirestoreUserWorkoutCollectionAPI: FirestoreUserCollectionAPI<Workout>, UserWorkoutCollectionAPI {}
class FirestoreUserMessageCollectionAPI: FirestoreUserCollectionAPI<Message>, UserMessageCollectionAPI {}

class FirestoreUserCollectionAPI<Item: DbIdentifiable> {
//: UserCollectionAPI {
    private let store = Firestore.firestore()
    
    private var currentUserId: () -> UserId?
    private let collectionName: String
    
    init(collectionName: String,
         currentUserId: @escaping () -> UserId?)
    {
        self.collectionName = collectionName
        self.currentUserId = currentUserId
    }
    
    private lazy var collection: CollectionReference =
        store.collection(collectionName)
    
    private func document(_ id: String? = nil) -> DocumentReference {
        id.map { collection.document($0) } ?? collection.document()
    }
    
    private func queryParams(owner: OwnerFilter, isSent: Bool? = true, orderingByDate: Bool = true) -> Query {
        var query = {
            switch owner {
            case .currentUser:
                guard let userId = currentUserId() else {
                    return collection.limit(to: 0) // No user authenticated, access is forbiden
                }
                return collection.whereField("userId", isEqualTo: userId)
            case .user(let userId):
                return collection.whereField("userId", isEqualTo: userId)
            case .any:
                return collection
            }
        }()

        if let isSent {
            query = query.whereField("isSent", isEqualTo: isSent)
        }
        
        if orderingByDate {
            query = query.order(by: "date", descending: true)
        }
        
        return query
    }
    
    func listPublisher(owner: OwnerFilter = .currentUser, isSent: Bool? = nil) -> AnyPublisher<[Item], Error> {
        queryParams(owner: owner, isSent: isSent).snapshotPublisherCustom()
            .tryMap { querySnapshot in
                try querySnapshot.documents.map { document in
                    try document.data(as: Item.self)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func save(_ item: Item, replaceAsNew: Bool = false) async throws -> String {
        if let dbId = item.dbId {
            if replaceAsNew {
                try await delete(id: dbId)
                return try await saveNew(item)
            }
            try await document(dbId).setData(from: item).value
            return dbId
        } else {
            return try await saveNew(item)
        }
    }
        
//    private func saveAsNew(oldId: String, _ item: Item, asNew : Bool = false) async throws -> String {
//        store.runTransaction { transaction, errorPointer in
//            try await transaction. deleteDocument(id)
//            try await saveNew(item)
//        }
//    }

    private func saveNew(_ item: Item) async throws -> String {
        let document = self.document()
        var item = item
        let dbId = document.documentID
        item.dbId = dbId
//        try document.setData(from: item) as Void
        try await document.setData(from: item).value
        return dbId
    }

    func delete(id: String) async throws {
        try await document(id).delete()
    }
}
