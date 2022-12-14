//
//  TestHelper.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 02/12/2022.
//

@testable import Swimmee

import XCTest

class SwimmeeUnitTesting {}

func BadContextCallInMockFail(file: StaticString = #filePath, line: UInt = #line) { XCTFail("Can't achieve test. Mock bad initialization", file: file, line: line) }

enum TestError: String, CustomError {
    var description: String { rawValue }

    case badContextCall
    case errorForTesting
    case fakeNetworkError
}
