//
//  FirebaseImageStorageAPI.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 18/10/2022.
//

import FirebaseStorage
import Foundation
import AVFoundation
import UIKit

class FirebaseImageStorageAPI {
    enum Err: Error {
        case imageMaxSizeExceeded
        case pngConversionError
    }

    let folderName = "photos"
    let imageMaxSize: Int64 = 1024 * 1024

    let storage = Storage.storage()

    func resize(uiimage: UIImage) -> UIImage {
        let maxSize = CGSize(width: 400, height: 400)

        let availableRect = AVFoundation.AVMakeRect(aspectRatio: uiimage.size, insideRect: .init(origin: .zero, size: maxSize))
        let targetSize = availableRect.size

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)

        let resizedImage = renderer.image { (context) in
            uiimage.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        return resizedImage
    }
    
    func imageStorageRef(uid: String) -> StorageReference {
        storage.reference().child("\(folderName)/\(uid).png")
    }

    func upload(uid: String, photo: UIImage) async throws {
        let resizedPhoto = resize(uiimage: photo)
        guard let png = resizedPhoto.pngData() else {
            throw Err.pngConversionError
        }
        guard png.count <= imageMaxSize else {
            throw Err.imageMaxSizeExceeded
        }
        _ = try await imageStorageRef(uid: uid).putDataAsync(png)
//        return try await photoStorageRef(uid: uid).downloadURL()
    }

    func downloadd(uid: String) async throws -> Data {
        return try await imageStorageRef(uid: uid).data(maxSize: imageMaxSize)
    }
    
    func deleteImage(uid: String) async throws {
        try await imageStorageRef(uid: uid).delete()
    }

}
