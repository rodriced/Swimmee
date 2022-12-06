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

class FirestoreProfileAPI: ProfileAPI {
    private let store = Firestore.firestore()
    private let collectionName = "Profiles"

    private lazy var collection: CollectionReference =
        store.collection(collectionName)

    private var currentUserId: () throws -> UserId

    init(currentUserId: @escaping () throws -> UserId) {
        self.currentUserId = currentUserId
    }

    private func documentReference(_ userId: String? = nil) throws -> DocumentReference {
        let userId = try currentUserId()
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

    func publisher(userId: String?) -> AnyPublisher<Profile, Error> {
        do {
            return try documentReference(userId).snapshotPublisher()
                .tryMap { document in
                    try document.data(as: Profile.self)
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }

    func loadCoachs() async throws -> [Profile] {
        return try await collection
            .whereField("userType", isEqualTo: "coach")
            .order(by: "lastName")
            .getDocuments()
            .documents.map { doc in
                try doc.data(as: Profile.self, decoder: Firestore.Decoder())
            }
    }

//    func coachsPublisher() -> AnyPublisher<[Profile], Error> {
//        return collection
//            .whereField("userType", isEqualTo: "coach")
//            .order(by: "lastName")
//            .snapshotPublisherCustom()
//            .tryMap { querySnapshot in
//                try querySnapshot.documents.map { document in
//                    try document.data(as: Profile.self)
//                }
//            }
//            .eraseToAnyPublisher()
//    }

//    func loadSwimmers() async throws -> [Profile] {
//        return try await collection
//            .whereField("userType", isEqualTo: "swimmer")
//            .order(by: "lastName")
//            .getDocuments()
//            .documents.map { doc in
//                try doc.data(as: Profile.self, decoder: Firestore.Decoder())
//            }
//    }

    func loadTeam() async throws -> [Profile] {
        let userId = try currentUserId()

        return try await collection
            .whereField("coachId", isEqualTo: userId)
            .order(by: "lastName")
            .getDocuments()
            .documents.map { doc in
                try doc.data(as: Profile.self, decoder: Firestore.Decoder())
            }
    }

    func updateCoach(with coachId: String?) async throws {
        try await documentReference().setData(["coachId": coachId as Any], merge: true)
    }

//    func updateCoach(for profile: inout Profile, with coachId: String?) async throws {
//        try await documentReference(profile.userId).setData(["coachId": coachId as Any], merge: true)
//        profile.coachId = coachId
//    }

    func setMessageAsRead(_ messageDbId: Message.DbId) async throws {
        let userId = try currentUserId()

        try await documentReference(userId).updateData(
            [Profile.CodingKeys.readMessagesIds.stringValue: FieldValue.arrayUnion([messageDbId])]
        )
    }
}
