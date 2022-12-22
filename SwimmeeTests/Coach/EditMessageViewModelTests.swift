//
//  EditMessageViewModelTests.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 19/12/2022.
//

@testable import Swimmee

import XCTest

final class EditMessageViewModelTests: XCTestCase {
    func testNotSentMessageValidation() {
        let messageAPI = MockUserMessageCollectionAPI()
        //        let aMessage = Samples.aMessage(userId: Samples.aUserId)
        
        let aMessage = Message(userId: Samples.aUserId, title: "A Title", content: "A content", isSent: false)
        
        let sut = EditMessageViewModel(message: aMessage, messageAPI: messageAPI)
        XCTAssertEqual(sut.validateTitle(), true)
        XCTAssertEqual(sut.canTryToSend, true)
        XCTAssertEqual(sut.canTryToSaveAsDraft, false)
        
        sut.message.title = "      " // Some spaces
        XCTAssertEqual(sut.validateTitle(), false)
        XCTAssertEqual(sut.canTryToSend, true)
        XCTAssertEqual(sut.canTryToSaveAsDraft, true)
        
        sut.message.title = "  A Title  "
        XCTAssertEqual(sut.validateTitle(), true)
        XCTAssertEqual(sut.canTryToSend, true)
        XCTAssertEqual(sut.canTryToSaveAsDraft, true)
    }
    
    func testSentMessageValidation() {
        let messageAPI = MockUserMessageCollectionAPI()
        //        let aMessage = Samples.aMessage(userId: Samples.aUserId)
        
        let aMessage = Message(userId: Samples.aUserId, title: "A Title", content: "A content", isSent: true)
        
        let sut = EditMessageViewModel(message: aMessage, messageAPI: messageAPI)
        XCTAssertEqual(sut.validateTitle(), true)
        XCTAssertEqual(sut.canTryToSend, false)
        XCTAssertEqual(sut.canTryToSaveAsDraft, true)
        
        sut.message.title = "      " // Some spaces
        XCTAssertEqual(sut.validateTitle(), false)
        XCTAssertEqual(sut.canTryToSend, true)
        XCTAssertEqual(sut.canTryToSaveAsDraft, true)
        
        sut.message.title = "  A Title  "
        XCTAssertEqual(sut.validateTitle(), true)
        XCTAssertEqual(sut.canTryToSend, true)
        XCTAssertEqual(sut.canTryToSaveAsDraft, true)
    }
    
    func testSaveAsDraftUnsentMessage() {
        let aMessage = Samples.aMessage(userId: Samples.aUserId, isSent: false)
        let newContent = "New cntent"
        //        let expectedSavedMessage = aMessage
        let expectedSavedMessage = {
            var message = aMessage
            message.content = newContent
            return message
        }()
        
        let messageAPI = MockUserMessageCollectionAPI()
        messageAPI.mockSave = { messageToSave, replaceAsNew in
            XCTAssertEqual(messageToSave, expectedSavedMessage)
            XCTAssertEqual(replaceAsNew, false)
            return expectedSavedMessage.userId
        }
        let sut = EditMessageViewModel(message: aMessage, messageAPI: messageAPI)
        
        sut.message.content = newContent
        
        sut.saveMessage(andSendIt: false, onValidationError: { XCTFail() })
    }
    
    func testSendUnsentMessage() {
        let aMessage = Samples.aMessage(userId: Samples.aUserId, isSent: false)
        var expectedSavedMessage = {
            var message = aMessage
            message.isSent = true
            return message
        }()
        
        let messageAPI = MockUserMessageCollectionAPI()
        messageAPI.mockSave = { messageToSave, replaceAsNew in
            XCTAssertNotEqual(messageToSave.date, expectedSavedMessage.date)
            expectedSavedMessage.date = messageToSave.date
            
            XCTAssertEqual(messageToSave, expectedSavedMessage)
            XCTAssertEqual(replaceAsNew, true)
            return expectedSavedMessage.userId
        }
        let sut = EditMessageViewModel(message: aMessage, messageAPI: messageAPI)
                
        sut.saveMessage(andSendIt: true, onValidationError: { XCTFail() })
    }
    
    func testSaveAsDraftSentMessage() {
        let aMessage = Samples.aMessage(userId: Samples.aUserId, isSent: true)
        let expectedSavedMessage = {
            var message = aMessage
            message.isSent = false
            return message
        }()
        
        let messageAPI = MockUserMessageCollectionAPI()
        messageAPI.mockSave = { messageToSave, replaceAsNew in
//            expectedSavedMessage.date = messageToSave.date
            XCTAssertEqual(messageToSave, expectedSavedMessage)
            XCTAssertEqual(replaceAsNew, false)
            return expectedSavedMessage.userId
        }
        let sut = EditMessageViewModel(message: aMessage, messageAPI: messageAPI)
                
        sut.saveMessage(andSendIt: false, onValidationError: { XCTFail() })
    }
    
    func testReplaceSentMessage() {
        let aMessage = Samples.aMessage(userId: Samples.aUserId, isSent: true)
        var expectedSavedMessage = aMessage
                
        let messageAPI = MockUserMessageCollectionAPI()
        messageAPI.mockSave = { messageToSave, replaceAsNew in
            XCTAssertNotEqual(messageToSave.date, expectedSavedMessage.date)
            expectedSavedMessage.date = messageToSave.date
            
            XCTAssertEqual(messageToSave, expectedSavedMessage)
            XCTAssertEqual(replaceAsNew, true)
            return expectedSavedMessage.userId
        }
        let sut = EditMessageViewModel(message: aMessage, messageAPI: messageAPI)
                
        sut.saveMessage(andSendIt: true, onValidationError: { XCTFail() })
    }

    func testSaveMessageWithValidationError() {
        let aMessage = Samples.aMessage(userId: Samples.aUserId, isSent: false)
        
        let messageAPI = MockUserMessageCollectionAPI()
        let sut = EditMessageViewModel(message: aMessage, messageAPI: messageAPI)
        sut.message.title = ""
        
        let expectation = expectation(description: "Waiting for onError")
        
        assertPublishedValue(sut.alertContext.$isPresented, equals: true) {
            sut.saveMessage(andSendIt: false, onValidationError: { expectation.fulfill() })
        }
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssertEqual(sut.alertContext.message, "Put something in title and retry.")
    }
    

    func testSaveMessageWithNetworkError() {
        let aMessage = Samples.aMessage(userId: Samples.aUserId, isSent: false)
        
        let messageAPI = MockUserMessageCollectionAPI()
        messageAPI.mockSave = { _, _ in
            throw TestError.fakeNetworkError
        }
        let sut = EditMessageViewModel(message: aMessage, messageAPI: messageAPI)
        sut.message.content = "New cntent"
        
        assertPublishedValue(sut.alertContext.$isPresented, equals: true) {
            sut.saveMessage(andSendIt: false, onValidationError: { XCTFail() })
        }
        
        XCTAssertEqual(sut.alertContext.message, "fakeNetworkError")
    }
    
    func testDeleteMessage() {
        let aMessage = Samples.aMessage(userId: Samples.aUserId, isSent: false)
        let expectedDeletedMessage = aMessage
        
        let messageAPI = MockUserMessageCollectionAPI()
        messageAPI.mockDelete = { messageToSaveUserId in
            XCTAssertEqual(messageToSaveUserId, expectedDeletedMessage.dbId)
        }
        let sut = EditMessageViewModel(message: aMessage, messageAPI: messageAPI)
                
        let expectation = expectation(description: "Waiting for completion")
        sut.deleteMessage(completion: { expectation.fulfill() })
        
        wait(for: [expectation], timeout: 1)
    }

    func testDeleteMessageWithNetworkError() {
        let aMessage = Samples.aMessage(userId: Samples.aUserId, isSent: false)
        
        let messageAPI = MockUserMessageCollectionAPI()
        messageAPI.mockDelete = { _ in
            throw TestError.fakeNetworkError
        }
        let sut = EditMessageViewModel(message: aMessage, messageAPI: messageAPI)
        
        assertPublishedValue(sut.alertContext.$isPresented, equals: true) {
            sut.deleteMessage(completion: { XCTFail() })
        }
        
        XCTAssertEqual(sut.alertContext.message, "fakeNetworkError")
    }
}
