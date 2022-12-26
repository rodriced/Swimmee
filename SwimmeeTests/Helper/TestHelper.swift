//
//  TestHelper.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 02/12/2022.
//

@testable import Swimmee

import XCTest

func MockFunctionNotInitialized(file: StaticString = #filePath, line: UInt = #line) { XCTFail("Mock function is called in a test, but it is not initialized has it should be.", file: file, line: line) }

enum TestError: String, CustomError {
    var description: String { rawValue }

    case errorForTesting
    case fakeNetworkError
}
