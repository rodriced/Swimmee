//
//  ImageStorageAPI.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 21/12/2022.
//

import Foundation

protocol ImageStorageAPI {
    func upload(_ name: String, with data: Data) async throws -> URL
    func download(_ name: String) async throws -> Data
    func delete(_ name: String) async throws
}
