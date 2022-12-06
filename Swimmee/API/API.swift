//
//  API.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 31/10/2022.
//

class API {
    static let shared = API()
    private init() {}

    let account = FirebaseAccountAPI()
    let imageStorage = FirebaseImageStorageAPI(folderPath: "photos")
    let profile = FirestoreProfileAPI(currentUserId: { try API.shared.account.getCurrentUserId() })
    let message = FirestoreUserMessageCollectionAPI(collectionName: "Messages", currentUserId: { API.shared.account.currentUserId })
    let workout = FirestoreUserWorkoutCollectionAPI(collectionName: "Workouts", currentUserId: { API.shared.account.currentUserId })
}
