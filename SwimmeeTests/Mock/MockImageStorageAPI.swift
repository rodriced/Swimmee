//
//  MockImageStorageAPI.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 04/12/2022.
//

@testable import Swimmee

import Foundation

class MockImageStorageAPI: ImageStorageAPI {
    var mockUpload: (String, Data) async throws -> URL = { _, _ in BadContextCallInMockFail(); fatalError() }
    var mockDownload: (String) async throws -> Data = { _ in BadContextCallInMockFail(); fatalError() }
    var mockDelete: (String) async throws -> Void = { _ in BadContextCallInMockFail(); fatalError() }

    func upload(_ name: String, with data: Data) async throws -> URL {
        return try await mockUpload(name, data)
    }

    func download(_ name: String) async throws -> Data {
        return try await mockDownload(name)
    }

    func delete(_ name: String) async throws {
        try await mockDelete(name)
    }
}
