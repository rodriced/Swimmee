//
//  TestHelper.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 02/12/2022.
//

//import Foundation

import XCTest

func BadContextCallInMockFail(file: StaticString = #filePath, line: UInt = #line) { XCTFail("Can't achieve test. Mock bad initialization", file: file, line: line) }

enum TestInternalError: Error {
    case badContextCall
}
