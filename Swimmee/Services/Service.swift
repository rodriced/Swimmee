//
//  Service.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 17/10/2022.
//

import FirebaseFirestore
import FirebaseStorage
import Foundation

class Service {
//    private init() {}
    static var shared = Service()

    let auth: FirebaseAuthService
    let storage: StorageService
    let store: StoreService

    init(auth: FirebaseAuthService = FirebaseAuthService(), storage: StorageService = StorageService(), store: StoreService = StoreService()) {
        self.auth = auth
        self.storage = storage
        self.store = store
    }
}
