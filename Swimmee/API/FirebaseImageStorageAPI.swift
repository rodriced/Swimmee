//
//  FirebaseImageStorageAPI.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 18/10/2022.
//

import FirebaseStorage
import Foundation
import UIKit

class FirebaseImageStorageAPI {
    enum Err: Error {
        case imageMaxSizeExceeded
    }

    let folderPath: String
    let imageMaxSize: Int64 = 1024 * 1024

    let storage = Storage.storage()
    
    init(folderPath: String) {
        self.folderPath = folderPath
    }
//    func imageStorageUrl(uid: String) throws -> URL {
//        imageStorageRef(uid: ui).downloadURL()
//    }
    
    func imageStorageRef(uid: String) -> StorageReference {
        storage.reference().child("\(folderPath)/\(uid).png")
    }

    func upload(uid: String, imageData: Data) async throws -> URL {
        guard imageData.count <= imageMaxSize else {
            throw Err.imageMaxSizeExceeded
        }
        let storageRef = imageStorageRef(uid: uid)
        _ = try await storageRef.putDataAsync(imageData)
        return try await storageRef.downloadURL()
    }

    func downloadd(uid: String) async throws -> Data {
        return try await imageStorageRef(uid: uid).data(maxSize: imageMaxSize)
    }
    
    func deleteImage(uid: String) async throws {
        try await imageStorageRef(uid: uid).delete()
    }

}
