//
//  SwimmerMessagesViewModelTests.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 12/12/2022.
//

@testable import Swimmee

import Combine
import XCTest

final class SwimmerMessagesViewModelTests: XCTestCase {
    func testLoading() throws {
        let aMessagesList = Samples.aMessagesList(userId: "COACH_ID")
        let readMeassagesIds = Set(aMessagesList[1 ... 2].map { $0.dbId! })

        let expectedMessagesParams = aMessagesList.map { (message: $0, isRead: readMeassagesIds.contains($0.dbId!)) }

        let profileAPI = MockProfilePI()
        let config = SwimmerMessagesViewModel.Config(profileAPI: profileAPI)

        let sut = SwimmerMessagesViewModel(initialData: (aMessagesList, Set(readMeassagesIds)), config: config)

        for (messageParams, expectedMessageParams) in zip(sut.messagesParams, expectedMessagesParams) {
            XCTAssertEqual(messageParams.message, expectedMessageParams.message)
            XCTAssertEqual(messageParams.isRead, expectedMessageParams.isRead)
        }

        XCTAssertEqual(sut.newMessagesCount, aMessagesList.count - readMeassagesIds.count)
    }

    func testSuccessfullSetMessageAsRead() {
        let aMessagesList = Samples.aMessagesList(userId: "COACH_ID")

        let profileAPI = MockProfilePI()
        profileAPI.mockSetMessageAsRead = { dbId in
            XCTAssertEqual(dbId, aMessagesList[0].dbId!)
        }

        let config = SwimmerMessagesViewModel.Config(profileAPI: profileAPI)
        let sut = SwimmerMessagesViewModel(initialData: (aMessagesList, []), config: config)

        sut.setMessageAsRead(sut.messagesParams[0].message)
    }
}
