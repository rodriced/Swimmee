//
//  PhotoInfoEditedTests.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 14/12/2022.
//

@testable import Swimmee

import XCTest

final class PhotoInfoEditedTests: XCTestCase {
    func mockPhotoInfoEdited(_ initialPhotoInfo: PhotoInfo?) -> PhotoInfoEdited {
        PhotoInfoEdited(initialPhotoInfo, imageStorage: MockImageStorageAPI())
    }

    func testInit() throws {
        var sut: PhotoInfoEdited

        sut = mockPhotoInfoEdited(nil)
        XCTAssertEqual(sut.state, .initial)
        XCTAssertEqual(sut.isImagePresent, false)

        sut = mockPhotoInfoEdited(Samples.aPhotoInfo)
        XCTAssertEqual(sut.state, .initial)
        XCTAssertEqual(sut.isImagePresent, true)
    }

    func testUpdateWorkflow() throws {
        var sut: PhotoInfoEdited

        let image1 = Samples.anUIImage(ref: 1)
        let image1Data = Samples.aPngImage(ref: 1)
        let image1PhotoInfo = Samples.aPhotoInfo(ref: 1)
        let image2 = Samples.anUIImage(ref: 2)
        let image2Data = Samples.aPngImage(ref: 2)

        // initial none -> initial none
        sut = mockPhotoInfoEdited(nil)
        sut.updateWith(uiImage: nil)
        XCTAssertEqual(sut.state, .initial)
        XCTAssertEqual(sut.isImagePresent, false)

        // initial none -> image1 -> initial none
        sut = mockPhotoInfoEdited(nil)
        sut.updateWith(uiImage: image1)
        XCTAssertEqual(sut.state, .new(uiImage: image1, data: image1Data, size: image1Data.count, hash: image1Data.hashValue))
        XCTAssertEqual(sut.isImagePresent, true)
        sut.updateWith(uiImage: nil)
        XCTAssertEqual(sut.state, .initial)
        XCTAssertEqual(sut.isImagePresent, false)

        // initial image1 -> removed -> initial image1
        sut = mockPhotoInfoEdited(image1PhotoInfo)
        sut.updateWith(uiImage: nil)
        XCTAssertEqual(sut.state, .removed)
        XCTAssertEqual(sut.isImagePresent, false)
        sut.updateWith(uiImage: image1)
        XCTAssertEqual(sut.state, .initial)
        XCTAssertEqual(sut.isImagePresent, true)

        // initial image1 -> initial image1
        sut = mockPhotoInfoEdited(image1PhotoInfo)
        sut.updateWith(uiImage: image1)
        XCTAssertEqual(sut.state, .initial)
        XCTAssertEqual(sut.isImagePresent, true)

        // initial image1 -> new image2 -> removed -> initial image1
        sut = mockPhotoInfoEdited(image1PhotoInfo)
        sut.updateWith(uiImage: image2)
        XCTAssertEqual(sut.state, .new(uiImage: image2, data: image2Data, size: image2Data.count, hash: image2Data.hashValue))
        XCTAssertEqual(sut.isImagePresent, true)
        sut.updateWith(uiImage: nil)
        XCTAssertEqual(sut.state, .removed)
        XCTAssertEqual(sut.isImagePresent, false)
        sut.updateWith(uiImage: image1)
        XCTAssertEqual(sut.state, .initial)
        XCTAssertEqual(sut.isImagePresent, true)

        // initial none -> image1 -> initial none
        sut = mockPhotoInfoEdited(nil)
        sut.updateWith(uiImage: image1)
        XCTAssertEqual(sut.state, .new(uiImage: image1, data: image1Data, size: image1Data.count, hash: image1Data.hashValue))
        XCTAssertEqual(sut.isImagePresent, true)
        sut.updateWith(uiImage: image2)
        XCTAssertEqual(sut.state, .new(uiImage: image2, data: image2Data, size: image2Data.count, hash: image2Data.hashValue))
        XCTAssertEqual(sut.isImagePresent, true)
        sut.updateWith(uiImage: nil)
        XCTAssertEqual(sut.state, .initial)
        XCTAssertEqual(sut.isImagePresent, false)
    }

    func testSuccessfullSave() async {
        let userId = "USER_ID"

        let image1 = Samples.anUIImage(ref: 1)
        let image1Data = Samples.aPngImage(ref: 1)
        let image1PhotoInfo = Samples.aPhotoInfo(ref: 1)
        let image1Url = Samples.anUrl(ref: 1)

        var imageStorageAPI: MockImageStorageAPI
        var sut: PhotoInfoEdited
        var saveResult: PhotoInfo?

        // initial image1
        imageStorageAPI = MockImageStorageAPI()
        sut = PhotoInfoEdited(image1PhotoInfo, imageStorage: imageStorageAPI)
        saveResult = await sut.save(as: userId)
        XCTAssertEqual(saveResult, image1PhotoInfo)

        // initial none
        imageStorageAPI = MockImageStorageAPI()
        sut = PhotoInfoEdited(nil, imageStorage: imageStorageAPI)
        saveResult = await sut.save(as: userId)
        XCTAssertEqual(saveResult, nil)

        // removed
        imageStorageAPI = MockImageStorageAPI()
        imageStorageAPI.mockDelete = { name in
            XCTAssertEqual(name, userId)
        }
        sut = PhotoInfoEdited(image1PhotoInfo, imageStorage: imageStorageAPI)
        sut.updateWith(uiImage: nil)
        saveResult = await sut.save(as: userId)
        XCTAssertEqual(saveResult, nil)

        // new
        imageStorageAPI = MockImageStorageAPI()
        imageStorageAPI.mockUpload = { name, data in
            XCTAssertEqual(name, userId)
            XCTAssertEqual(data, image1Data)
            return image1Url
        }
        sut = PhotoInfoEdited(nil, imageStorage: imageStorageAPI)
        sut.updateWith(uiImage: image1)
        saveResult = await sut.save(as: userId)
        XCTAssertEqual(saveResult, image1PhotoInfo)
    }

    func testFailingSave() async {
        let userId = "SER_ID"

        let image1 = Samples.anUIImage(ref: 1)
        let image1PhotoInfo = Samples.aPhotoInfo(ref: 1)

        var imageStorageAPI: MockImageStorageAPI
        var sut: PhotoInfoEdited
        var saveResult: PhotoInfo?

        // saving removed image
        imageStorageAPI = MockImageStorageAPI()
        imageStorageAPI.mockDelete = { _ in
            throw TestError.fakeNetworkError
        }
        sut = PhotoInfoEdited(image1PhotoInfo, imageStorage: imageStorageAPI)
        sut.updateWith(uiImage: nil)
        saveResult = await sut.save(as: userId)
        XCTAssertEqual(saveResult, nil)

        // saving new image
        imageStorageAPI = MockImageStorageAPI()
        imageStorageAPI.mockUpload = { _, _ in
            throw TestError.fakeNetworkError
        }
        sut = PhotoInfoEdited(nil, imageStorage: imageStorageAPI)
        sut.updateWith(uiImage: image1)
        saveResult = await sut.save(as: userId)
        XCTAssertEqual(saveResult, nil)
    }
}
