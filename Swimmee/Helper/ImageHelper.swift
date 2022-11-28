//
//  ImageHelper.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 28/11/2022.
//

//import Foundation
import AVFoundation
import UIKit

class ImageHelper {
    enum Err: Error {
        case pngConversionError
    }
    
    static func resize(uiimage: UIImage, to size: CGFloat = 400) -> UIImage {
        let finalSize = CGSize(width: size, height: size)

        let availableRect = AVFoundation.AVMakeRect(aspectRatio: uiimage.size, insideRect: .init(origin: .zero, size: finalSize))
        let targetSize = availableRect.size

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)

        let resizedImage = renderer.image { (context) in
            uiimage.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        return resizedImage
    }
    
    static func resizedImageData(from uiImage: UIImage, size: CGFloat = 400) throws -> Data {
        let resizedImage = ImageHelper.resize(uiimage: uiImage, to: size)
        
        guard let imageData = resizedImage.pngData() else {
            throw Err.pngConversionError
        }
        
        return imageData
    }
}
