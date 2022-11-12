//
//  FirestoreProfileAPI.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 19/10/2022.
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

class FirestoreProfileAPI {
    let store = Firestore.firestore()
    let collectionName = "Profiles"

    lazy var collection: CollectionReference =
        store.collection(collectionName)

    func document(_ id: String? = nil) -> DocumentReference {
        id.map { collection.document($0) } ?? collection.document()
    }

    func save(_ profile: Profile) async throws {
        try document(profile.userId).setData(from: profile) as Void
    }

    func load(userId: String) async throws -> Profile {
        return try await document(userId).getDocument(as: Profile.self)
    }

    func delete(userId: String) async throws {
        return try await document(userId).delete()
    }

//    func profileFuture(userId: String) -> Future<Profile, Error> {
    func future(userId: String) -> AnyPublisher<Profile, Error> {
        (document(userId).getDocument() as Future<DocumentSnapshot, Error>)
            .tryMap { document in
                try document.data(as: Profile.self)
            }
//            .decode(type: Profile.self, decoder: Firestore.Decoder())
//            .eraseToAnyPublisher()
            .eraseToAnyPublisher()
    }

    func loadCoachs() async throws -> [Profile] {
        return try await collection.whereField("userType", isEqualTo: "coach").getDocuments()
            .documents.map { doc in
                try doc.data(as: Profile.self, decoder: Firestore.Decoder())
            }
    }
    
    func coachsPublisher() -> AnyPublisher<[Profile], Error> {
        return collection.whereField("userType", isEqualTo: "coach").snapshotPublisher()
            .tryMap { querySnapshot in
                try querySnapshot.documents.map { document in
                    try document.data(as: Profile.self)
                }
            }
            .eraseToAnyPublisher()
    }


    func loadSwimmers() async throws -> [Profile] {
        return try await collection.whereField("userType", isEqualTo: "swimmer").getDocuments()
            .documents.map { doc in
                try doc.data(as: Profile.self, decoder: Firestore.Decoder())
            }
    }

    func loadTeam(coachId: String) async throws -> [Profile] {
        return try await collection.whereField("coachId", isEqualTo: coachId).getDocuments()
            .documents.map { doc in
                try doc.data(as: Profile.self, decoder: Firestore.Decoder())
            }
    }

    func updateCoach(for userId: String, with coachId: String?) async throws {
        try await document(userId).setData(["coachId": coachId as Any], merge: true)
    }

    func updateCoach(for profile: inout Profile, with coachId: String?) async throws {
        try await document(profile.userId).setData(["coachId": coachId as Any], merge: true)
        profile.coachId = coachId
    }
}
