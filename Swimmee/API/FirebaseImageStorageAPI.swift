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
    private enum Err: Error {
        case imageMaxSizeExceeded
    }

    private let folderPath: String
    private let imageMaxSize: Int64 = 1024 * 1024

    private let storage = Storage.storage()
    
    init(folderPath: String) {
        self.folderPath = folderPath
    }
//    func imageStorageUrl(uid: String) throws -> URL {
//        imageStorageRef(uid: ui).downloadURL()
//    }
    
    private func storageRef(for name: String) -> StorageReference {
        storage.reference().child("\(folderPath)/\(name).png")
    }

    func upload(_ name: String, with data: Data) async throws -> URL {
        guard data.count <= imageMaxSize else {
            throw Err.imageMaxSizeExceeded
        }
        let storageRef = storageRef(for: name)
        _ = try await storageRef.putDataAsync(data)
        return try await storageRef.downloadURL()
    }

    func download(_ name: String) async throws -> Data {
        return try await storageRef(for: name).data(maxSize: imageMaxSize)
    }
    
    func delete(_ name: String) async throws {
        try await storageRef(for: name).delete()
    }

}
