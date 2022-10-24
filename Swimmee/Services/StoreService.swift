//
//  StoreService.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 19/10/2022.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class StoreService {
    static var store = Firestore.firestore()
    
    func saveProfile(profile: Profile) async throws {
        try Self.store.collection("Profiles").document(profile.userId).setData(from: profile)
    }
    
    func loadProfile(userId: String) async throws -> Profile? {
        return try await Self.store.collection("Profiles").document(userId).getDocument(as: Profile?.self)
    }
    
}
