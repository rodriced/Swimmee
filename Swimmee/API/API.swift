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
    
//    let auth = FirebaseAuthAPI()
    let account = FirebaseAccountAPI()
    let imageStorage = FirebaseImageStorageAPI(folderPath: "photos")
    let profile = FirestoreProfileAPI(currentUserId: { try API.shared.account.getCurrentUserId() } )
    let message = FirestoreCollectionAPI<Message>(collectionName: "Messages", currentUserId: { API.shared.account.currentUserId })
}
