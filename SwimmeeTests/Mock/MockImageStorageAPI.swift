//
//  MockImageStorageAPI.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 04/12/2022.
//

@testable import Swimmee

import Foundation

class MockImageStorageAPI: ImageStorageAPI {
    var mockUpload: () async throws -> URL = { BadContextCallInMockFail(); fatalError() }
    var mockDownload: () async throws -> Data = { BadContextCallInMockFail(); fatalError() }
    var mockDelete: () async throws -> Void = { BadContextCallInMockFail(); fatalError() }

    func upload(_ name: String, with data: Data) async throws -> URL {
        return try await mockUpload()
    }

    func download(_ name: String) async throws -> Data {
        return try await mockDownload()
    }

    func delete(_ name: String) async throws {
        try await mockDelete()
    }
}
