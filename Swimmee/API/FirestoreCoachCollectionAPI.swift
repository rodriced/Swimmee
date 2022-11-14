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

// protocol ModelAPI {
//    associatedtype Model
//
//    func save(model: Model) async throws
// }

protocol DbIdentifiable: Codable {
    var dbId: String? { get set }
}

class FirestoreCoachCollectionAPI<Item: DbIdentifiable> {
    enum CollectionFilter {
        case currentUser
        case user(UserId)
        case all
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
    
    private func query(filter: CollectionFilter) -> Query {
        switch filter {
        case .currentUser:
            guard let userId = currentUserId() else {
                return collection.limit(to: 0)
            }
            return collection.whereField("userId", isEqualTo: userId)
        case .user(let userId):
            return collection.whereField("userId", isEqualTo: userId)
        case .all:
            return collection
        }
    }

    func save(_ item: Item) async throws -> String {
        if let dbId = item.dbId {
            try document(dbId).setData(from: item) as Void
            return dbId
        } else {
            let document = self.document()
            var item = item
            let dbId = document.documentID
            item.dbId = dbId
            try document.setData(from: item) as Void
            return dbId
        }
        //        try document(item[keyPath: idKeyPath]).setData(from: item) as Void
        //        try document(item[keyPath: idKeyPath]).setData(from: item) as Void
    }
    
    func load(id: String) async throws -> Item {
        try await document(id).getDocument(as: Item.self)
    }
    
    func delete(id: String) async throws {
        try await document(id).delete()
    }
    
    func loadList(filter: CollectionFilter = .currentUser) async throws -> [Item] {
        try await query(filter: filter).getDocuments()
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
    
    func listFuture(filter: CollectionFilter = .currentUser) -> AnyPublisher<[Item], Error> {
        query(filter: filter).getDocuments()
            .tryMap { querySnapshot in
                try querySnapshot.documents.map { documentSnapshot in
                    try documentSnapshot.data(as: Item.self)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func listPublisher(filter: CollectionFilter = .currentUser) -> AnyPublisher<[Item], Error> {
        query(filter: filter).snapshotPublisher()
            .tryMap { querySnapshot in
                try querySnapshot.documents.map { document in
                    try document.data(as: Item.self)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func listPublisher(filter: CollectionFilter = .currentUser) -> AnyPublisher<Result<[Item], Error>, Never> {
        query(filter: filter).snapshotPublisher()
            .tryMap { querySnapshot in
                try querySnapshot.documents.map { document in
                    try document.data(as: Item.self)
                }
            }
            .asResult()
            .eraseToAnyPublisher()
    }
    
    class ListPublisherTestError: LocalizedError {
        var errorDescription = "Erroro : ListPublisherTestError"
    }
    
    func listPublisherTest(filter: CollectionFilter = .currentUser) -> AnyPublisher<Result<[Item], Error>, Never> {
        query(filter: filter).snapshotPublisher()
            .tryMap { querySnapshot in
                if (0 ... 9).randomElement() ?? 0 < 4 { throw ListPublisherTestError() }
                return try querySnapshot.documents.map { document in
                    try document.data(as: Item.self)
                }
            }
            .asResult()
            .eraseToAnyPublisher()
    }
    
    func listPublisherBuilder(filter: CollectionFilter = .currentUser) -> (() -> AnyPublisher<Result<[Item], Error>, Never>) {
        { [self] in
            query(filter: filter).snapshotPublisher()
                .tryMap { querySnapshot in
                    try querySnapshot.documents.map { document in
                        try document.data(as: Item.self)
                    }
                }
                .asResult()
                .eraseToAnyPublisher()
        }
    }
}
