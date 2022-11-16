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

//enum ProfileError: LocalizedError {
//    case profileNotFound
//}

class FirestoreProfileAPI {
    private let store = Firestore.firestore()
    private let collectionName = "Profiles"

    private lazy var collection: CollectionReference =
        store.collection(collectionName)

    private var currentUserId: () throws -> UserId
    
    init(currentUserId: @escaping () throws -> UserId)
    {
        self.currentUserId = currentUserId
    }

    private func documentReference(_ userId: String? = nil) throws -> DocumentReference {
        let userId = try {
            guard let userId else {
                return try self.currentUserId()
            }
            return userId
        }()
//        guard let userId = userId ?? currentUserId() else {
//            throw AuthError.notAuthenticated
//        }
        return collection.document(userId)
    }

    func save(_ profile: Profile) async throws {
        try documentReference(profile.userId).setData(from: profile) as Void
    }

    func load(userId: String) async throws -> Profile {
        return try await documentReference(userId).getDocument(as: Profile.self)
    }

    func delete(userId: String) async throws {
        return try await documentReference(userId).delete()
    }

    func future(userId: String?) -> AnyPublisher<Profile, Error> {
        do {
            return (try documentReference(userId).getDocument() as Future<DocumentSnapshot, Error>)
                .tryMap { document in
                    try document.data(as: Profile.self)
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
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

    func updateCoach(for userId: String? = nil, with coachId: String?) async throws {
        try await documentReference(userId).setData(["coachId": coachId as Any], merge: true)
    }

    func updateCoach(for profile: inout Profile, with coachId: String?) async throws {
        try await documentReference(profile.userId).setData(["coachId": coachId as Any], merge: true)
        profile.coachId = coachId
    }
}
