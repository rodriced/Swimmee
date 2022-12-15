//
//  WorkoutTests.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 15/12/2022.
//

@testable import Swimmee

import XCTest

final class MessageTests: XCTestCase {
    func testIsNew() {
        var aMessage = Samples.aMessage(userId: Samples.aUserId)
     
        aMessage.dbId = nil
        XCTAssertEqual(aMessage.isNew, true)

        aMessage.dbId = Samples.aRandomDbId
        XCTAssertEqual(aMessage.isNew, false)
    }
    
    func testHasTextDifferent() {
        let message1 = Message(userId: Samples.aUserId(ref: 1), title: "A Title", content: "A content")
        let message2 = Message(userId: Samples.aUserId(ref: 2), title: "Another Title", content: "A content")
        let message3 = Message(userId: Samples.aUserId(ref: 3), title: "A Title", content: "Another content")
        let message4 = Message(userId: Samples.aUserId(ref: 4), title: "Another Title", content: "Another content")

        XCTAssertEqual(message1.hasTextDifferent(from: message1), false)
        XCTAssertEqual(message1.hasTextDifferent(from: message2), true)
        XCTAssertEqual(message1.hasTextDifferent(from: message3), true)
        XCTAssertEqual(message1.hasTextDifferent(from: message4), true)
    }

}
