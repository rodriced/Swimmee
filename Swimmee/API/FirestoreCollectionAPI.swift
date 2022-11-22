//
//  FirestoreCoachCollectionAPI.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 30/10/2022.
//

import Combine
import FirebaseFirestore
import FirebaseFirestoreCombineSwift
import FirebaseFirestoreSwift
import Foundation

protocol DbIdentifiable: Codable {
    var dbId: String? { get set }
}

class FirestoreCollectionAPI<Item: DbIdentifiable> {
    enum OwnerFilter {
        case currentUser
        case user(UserId)
        case any
    }
    
    enum IsSendedFilter {
        case sended
        case notSended
        case any
    }
    
    var currentUserId: () -> UserId?
    
    let store = Firestore.firestore()
    let collectionName: String
    
    init(collectionName: String,
         currentUserId: @escaping () -> UserId?)
    {
        self.collectionName = collectionName
        self.currentUserId = currentUserId
    }
    
    lazy var collection: CollectionReference =
        store.collection(collectionName)
    
    func document(_ id: String? = nil) -> DocumentReference {
        id.map { collection.document($0) } ?? collection.document()
    }
    
    func queryBy(owner: OwnerFilter, isSended: IsSendedFilter = .sended, orderingByDate: Bool = true) -> Query {
        var query = {
            switch owner {
            case .currentUser:
                guard let userId = currentUserId() else {
                    return collection.limit(to: 0)
                }
                return collection.whereField("userId", isEqualTo: userId)
            case .user(let userId):
                return collection.whereField("userId", isEqualTo: userId)
            case .any:
                return collection
            }
        }()
        
        query = {
            switch isSended {
            case .sended:
                return query.whereField("isSended", isEqualTo: true)
            case .notSended:
                return query.whereField("isSended", isEqualTo: false)
            case .any:
                return query
            }
        }()
        
        query = orderingByDate ?
            query.order(by: "date", descending: true)
            : query
        
        return query
    }
    
    private func saveAsNew(oldId: String, _ item: Item, asNew: Bool = false) async throws -> String {
        try await delete(id: oldId)
        return try await saveNew(item)
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

    func save(_ item: Item, asNew: Bool = false) async throws -> String {
        if let dbId = item.dbId {
            if asNew {
                return try await saveAsNew(oldId: dbId, item)
            }
            try await document(dbId).setData(from: item).value
            return dbId
        } else {
            return try await saveNew(item)
        }
    }
    
    func load(id: String) async throws -> Item {
        try await document(id).getDocument(as: Item.self)
    }
    
    func delete(id: String) async throws {
        try await document(id).delete()
    }
    
    func loadList(owner: OwnerFilter = .currentUser) async throws -> [Item] {
        try await queryBy(owner: owner).getDocuments()
            .documents.map { doc in
                try doc.data(as: Item.self, decoder: Firestore.Decoder())
            }
    }

    func future(id: String) -> AnyPublisher<Item, Error> {
        (document(id).getDocument() as Future<DocumentSnapshot, Error>)
            .tryMap { documentSnapshot in
                try documentSnapshot.data(as: Item.self)
            }
            .eraseToAnyPublisher()
    }
    
    func publisher(id: String) -> AnyPublisher<Item, Error> {
        document(id).snapshotPublisher()
            .tryMap { documentSnapshot in
                try documentSnapshot.data(as: Item.self)
            }
            .eraseToAnyPublisher()
    }
    
    func listFuture(owner: OwnerFilter = .currentUser) -> AnyPublisher<[Item], Error> {
        queryBy(owner: owner).getDocuments()
            .tryMap { querySnapshot in
                try querySnapshot.documents.map { documentSnapshot in
                    try documentSnapshot.data(as: Item.self)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func listPublisher(owner: OwnerFilter = .currentUser, isSended: IsSendedFilter = .sended) -> AnyPublisher<[Item], Error> {
        queryBy(owner: owner, isSended: isSended).snapshotPublisherCustom()
            .tryMap { querySnapshot in
                try querySnapshot.documents.map { document in
                    try document.data(as: Item.self)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func listPublisher(owner: OwnerFilter = .currentUser) -> AnyPublisher<Result<[Item], Error>, Never> {
        queryBy(owner: owner).snapshotPublisherCustom()
            .tryMap { querySnapshot in
                try querySnapshot.documents.map { document in
                    try document.data(as: Item.self)
                }
            }
            .asResult()
            .eraseToAnyPublisher()
    }
}
