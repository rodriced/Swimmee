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
    var dbId: String? {get set}
}

class FirestoreCoachCollectionAPI<Item: DbIdentifiable> {
    let store = Firestore.firestore()
    let collectionName: String

    init(collectionName: String) {
        self.collectionName = collectionName
    }

    lazy var collection: CollectionReference =
        store.collection(collectionName)

    func document(_ id: String? = nil) -> DocumentReference {
        id.map {collection.document($0)} ?? collection.document()
    }

//    func getDocument(id: String) -> Future<DocumentSnapshot, Error> {
//        collection.document(id).getDocument()
//    }

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

    func loadList(userId: String? = nil) async throws -> [Item] {
        let documentsSnapshot: QuerySnapshot = try await {
            if let userId = userId {
                return try await collection.whereField("userId", isEqualTo: userId).getDocuments()
            } else {
                return try await collection.getDocuments()
            }
        }()
        
        return try documentsSnapshot
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

    func listFuture(userId: String? = nil) -> AnyPublisher<[Item], Error> {
        let documentsFuture =
            userId.map { collection.whereField("userId", isEqualTo: $0).getDocuments() }
                ?? collection.getDocuments()
        return documentsFuture
            .tryMap { querySnapshot in
                try querySnapshot.documents.map { documentSnapshot in
                    try documentSnapshot.data(as: Item.self)
                }
            }
            .eraseToAnyPublisher()
    }

    func listPublisher(userId: String? = nil) -> AnyPublisher<[Item], Error> {
        let snapshotPublisher =
            userId.map { collection.whereField("userId", isEqualTo: $0).snapshotPublisher() }
                ?? collection.snapshotPublisher()
        return snapshotPublisher
            .tryMap { querySnapshot in
                try querySnapshot.documents.map { document in
                    try document.data(as: Item.self)
                }
            }
            .eraseToAnyPublisher()
    }
}
