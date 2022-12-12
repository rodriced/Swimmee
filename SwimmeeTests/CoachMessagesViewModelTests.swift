//
//  CoachMessagesViewModelTests.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 12/12/2022.
//

@testable import Swimmee

import Combine
import XCTest

final class CoachMessagesViewModelTests: XCTestCase {
    func testLoadingWithoutAndWithFilter() throws {
        var aMessagesList = Samples.aMessagesList(userId: "COACH_ID")
        aMessagesList[1].isSent = true
        aMessagesList[2].isSent = true

        let expectedDraftMessages = aMessagesList.filter { !$0.isSent }
        let expectedSentMessages = aMessagesList.filter { $0.isSent }

        let messageAPI = MockUserMessageCollectionAPI()
        let config = CoachMessagesViewModel.Config(messageAPI: messageAPI)

        let sut = CoachMessagesViewModel(initialData: aMessagesList, config: config)

        XCTAssertEqual(sut.filter, .all)
        
        XCTAssertEqual(sut.messages, aMessagesList)
        XCTAssertEqual(sut.filteredMessages, aMessagesList)

        sut.filter = .draft

        XCTAssertEqual(sut.messages, aMessagesList)
        XCTAssertEqual(sut.filteredMessages, expectedDraftMessages)
        
        sut.filter = .sent

        XCTAssertEqual(sut.messages, aMessagesList)
        XCTAssertEqual(sut.filteredMessages, expectedSentMessages)
    }

    func testGoEditingMessage() {
        let aMessagesList = Samples.aMessagesList(userId: "COACH_ID")
        var aMessage = aMessagesList[0]

        let messageAPI = MockUserMessageCollectionAPI()
        let config = CoachMessagesViewModel.Config(messageAPI: messageAPI)

        let sut = CoachMessagesViewModel(initialData: aMessagesList, config: config)

        XCTAssertEqual(sut.selectedMessage, nil)
        XCTAssertFalse(sut.sentMessageEditionConfirmationDialogPresented)
        XCTAssertFalse(sut.navigatingToEditView)
        
        aMessage.isSent = false
        sut.goEditingMessage(aMessage)

        XCTAssertEqual(sut.selectedMessage, aMessage)
        XCTAssertFalse(sut.sentMessageEditionConfirmationDialogPresented)
        XCTAssertTrue(sut.navigatingToEditView)

        aMessage.isSent = true
        sut.goEditingMessage(aMessage)

        XCTAssertEqual(sut.selectedMessage, aMessage)
        XCTAssertTrue(sut.sentMessageEditionConfirmationDialogPresented)
        XCTAssertFalse(sut.navigatingToEditView)
    }

    func testSuccessfullDeleteMessage() {
        let aMessagesList = Samples.aMessagesList(userId: "COACH_ID")
        let aMessage = aMessagesList[1]

        var expectedUpdatedMessagesList = aMessagesList
        expectedUpdatedMessagesList.remove(at: 1)

        let messageAPI = MockUserMessageCollectionAPI()
        messageAPI.mockDelete = { messageDbId in
            XCTAssertEqual(messageDbId, aMessage.dbId!)
        }
        let config = CoachMessagesViewModel.Config(messageAPI: messageAPI)

        let sut = CoachMessagesViewModel(initialData: aMessagesList, config: config)

        assertPublishedValue(
            sut.$messages,
            equals: expectedUpdatedMessagesList
        ) {
            sut.deleteMessage(at: IndexSet(integer: 1))
        }
    }

    func testDeleteMessageWithError() {
        let aMessagesList = Samples.aMessagesList(userId: "COACH_ID")

        let messageAPI = MockUserMessageCollectionAPI()
        messageAPI.mockDelete = { _ in
            throw TestError.fakeNetworkError
        }
        let config = CoachMessagesViewModel.Config(messageAPI: messageAPI)

        let sut = CoachMessagesViewModel(initialData: aMessagesList, config: config)

        XCTAssertFalse(sut.alertContext.isPresented)
        
        assertPublishedValue(
            sut.alertContext.$isPresented,
            equals: true
        ) {
            sut.deleteMessage(at: IndexSet(integer: 1))
        }
        
        XCTAssertEqual(sut.alertContext.message, "fakeNetworkError")
    }
}
