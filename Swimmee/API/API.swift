//
//  API.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 31/10/2022.
//

//import Foundation

class API {
    static let shared = API()
    private init() {}
    
    let auth = FirebaseAuthAPI()
    let imageStorage = FirebaseImageStorageAPI()
    let profile = FirestoreProfileAPI()
    let message = FirestoreCoachCollectionAPI<Message>(collectionName: "Messages")
}
