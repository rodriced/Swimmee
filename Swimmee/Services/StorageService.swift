//
//  StorageService.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 18/10/2022.
//

import FirebaseStorage
import Foundation
import AVFoundation
import UIKit

class StorageService {
    enum Err: Error {
        case photoMaxSizeExceeded
        case pngConversionError
    }

    let photosFolder = "photos"
    let photoMaxSize: Int64 = 1024 * 1024

    let storage = Storage.storage()

    func resizePhoto(image: UIImage) -> UIImage {
        let maxSize = CGSize(width: 400, height: 400)

        let availableRect = AVFoundation.AVMakeRect(aspectRatio: image.size, insideRect: .init(origin: .zero, size: maxSize))
        let targetSize = availableRect.size

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)

        let resizedImage = renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        return resizedImage
    }
    
    func photoStorageRef(uid: String) -> StorageReference {
        storage.reference().child("\(photosFolder)/\(uid).png")
    }

    func uploadPhoto(uid: String, photo: UIImage) async throws {
        let resizedPhoto = resizePhoto(image: photo)
        guard let png = resizedPhoto.pngData() else {
            throw Err.pngConversionError
        }
        guard png.count <= photoMaxSize else {
            throw Err.photoMaxSizeExceeded
        }
        _ = try await photoStorageRef(uid: uid).putDataAsync(png)
//        return try await photoStorageRef(uid: uid).downloadURL()
    }

    func downloaddPhoto(uid: String) async throws -> Data {
        return try await photoStorageRef(uid: uid).data(maxSize: photoMaxSize)
    }
    
    func removePhoto(uid: String) async throws {
        try await photoStorageRef(uid: uid).delete()
    }

}
