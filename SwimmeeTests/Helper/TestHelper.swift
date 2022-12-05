//
//  TestHelper.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 02/12/2022.
//

@testable import Swimmee

import UIKit
import XCTest

class SwimmeeUnitTesting {}

func BadContextCallInMockFail(file: StaticString = #filePath, line: UInt = #line) { XCTFail("Can't achieve test. Mock bad initialization", file: file, line: line) }

enum TestError: String, CustomError {
    var description: String { rawValue }

    case badContextCall
    case errorForTesting
}

enum TestHelper {
    static let fakeUrl = URL(string: "https://a.fake.url")!
    
    static var fakeUIImage: UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10))

        let image = renderer.image { context in
            UIColor.darkGray.setStroke()
            context.stroke(renderer.format.bounds)
            UIColor.blue.setFill()
            context.fill(CGRect(x: 1, y: 1, width: 5, height: 5))
        }
        return image
    }
    
    static var fakePngImage: Data {
        try! ImageHelper.resizedImageData(from: fakeUIImage)
    }
    
    static var fakePhotoInfo: PhotoInfo {
        PhotoInfo(url: fakeUrl, data: fakePngImage)
    }
}
