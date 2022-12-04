//
//  SignSharedViewModelTests.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 01/12/2022.
//

@testable import Swimmee

import Combine
import XCTest

final class SignSharedViewModelTests: XCTestCase {
    enum SubmitType: CaseIterable {
        case signUp, signIn, reauthenticate
        
        var formType: SignSharedViewModel.FormType {
            switch self {
            case .signUp:
                return .signUp
            case .signIn, .reauthenticate:
                return .signIn
            }
        }
    }
    
    private func GivenNewForm_WhenNoAction_ThenFormHaveNoErrorAndFieldsEmpty(submitType: SubmitType) {
        let sut = SignSharedViewModel(formType: submitType.formType, accountAPI: MockAccountAPI())

        XCTAssertEqual(sut.email, "")
        XCTAssertEqual(sut.password, "")
        
        XCTAssertFalse(sut.emailInError)
        XCTAssertFalse(sut.passwordInError)
        
        if submitType.formType == .signUp {
            XCTAssertNil(sut.userType)
            XCTAssertEqual(sut.firstName, "")
            XCTAssertEqual(sut.lastName, "")
            
            XCTAssertFalse(sut.userTypeInError)
            XCTAssertFalse(sut.firstNameInError)
            XCTAssertFalse(sut.lastNameInError)
        }

        XCTAssertFalse(sut.isReadyToSubmit)
    }
    
    func testGivenNewFormsOfEachType_WhenNoAction_ThenFormHaveNoErrorAndFieldsEmpty() {
        for submitType in SubmitType.allCases {
            GivenNewForm_WhenNoAction_ThenFormHaveNoErrorAndFieldsEmpty(submitType: submitType)
        }
    }

    private func GivenNewForm_WhenSubmited_ThenFormHaveErrors(submitType: SubmitType) {
        let sut = SignSharedViewModel(formType: submitType.formType, accountAPI: MockAccountAPI())

        switch submitType {
        case .signUp:
            sut.signUp()
        case .signIn:
            sut.signIn()
        case .reauthenticate:
            sut.reauthenticate()
        }
        
        XCTAssertFalse(sut.submitSuccess)
        
        XCTAssertTrue(sut.emailInError)
        XCTAssertTrue(sut.passwordInError)
        
        if submitType.formType == .signUp {
            XCTAssertTrue(sut.userTypeInError)
            XCTAssertTrue(sut.firstNameInError)
            XCTAssertTrue(sut.lastNameInError)
        }
        
        XCTAssertEqual(sut.errorAlertMessage, SignSharedViewModel.formValidationErrorMessage)
    }

    func testGivenNewFormsOfEachType_WhenSubmited_ThenFormHaveErrors() {
        for submitType in SubmitType.allCases {
            GivenNewForm_WhenSubmited_ThenFormHaveErrors(submitType: submitType)
        }
    }

    private func GivenCorrectValuesEnteredInForm_WhenSubmitSucceed_ThenFormHaveNoError(submitType: SubmitType) {
        let aProfile = Profile.coachSample
        
        let mockAccountAPI = MockAccountAPI()
        mockAccountAPI.mockSignUp = { aProfile }
        mockAccountAPI.mockSignIn = { aProfile }
        mockAccountAPI.mockReauthenticate = {}

        let sut = SignSharedViewModel(formType: submitType.formType, accountAPI: mockAccountAPI)
        
        let expectation1 = publisherExpectation(
            sut.$submitSuccess.dropFirst(),
            equals: true
        )
        
        sut.email = aProfile.email
        sut.password = "a password"
        
        if submitType.formType == .signUp {
            sut.userType = aProfile.userType
            sut.firstName = aProfile.firstName
            sut.lastName = aProfile.lastName
        }
        
        switch submitType {
        case .signUp:
            sut.signUp()
        case .signIn:
            sut.signIn()
        case .reauthenticate:
            sut.reauthenticate()
        }
        
        XCTAssertFalse(sut.emailInError)
        XCTAssertFalse(sut.passwordInError)
        
        if submitType.formType == .signUp {
            XCTAssertFalse(sut.userTypeInError)
            XCTAssertFalse(sut.firstNameInError)
            XCTAssertFalse(sut.lastNameInError)
        }
        
        XCTAssertFalse(sut.errorAlertIsPresenting)
        
        wait(for: [expectation1], timeout: 5)
    }

    func testGivenCorrectValuesEnteredInFormsOfEachType_WhenSubmitSucceed_ThenFormHaveNoError() {
        for submitType in SubmitType.allCases {
            GivenCorrectValuesEnteredInForm_WhenSubmitSucceed_ThenFormHaveNoError(submitType: submitType)
        }
    }
    
    private func             GivenCorrectValuesEnteredInForm_WhenSubmitFail_ThenFormHaveErrors(submitType: SubmitType) {
        let aProfile = Profile.coachSample
        
        let mockAccountAPI = MockAccountAPI()
        mockAccountAPI.mockSignUp = { throw TestError.errorForTesting }
        mockAccountAPI.mockSignIn = { throw TestError.errorForTesting }
        mockAccountAPI.mockReauthenticate = { throw TestError.errorForTesting }

        let sut = SignSharedViewModel(formType: submitType.formType, accountAPI: mockAccountAPI)
        
        let expectation1 = publisherExpectation(
            //            sut.$submitSuccess.print("$submitSuccess").removeDuplicates().first { $0 == false },
            sut.$submitSuccess,
            equals: false
        )

        let expectation2 = publisherExpectation(
            //            sut.$errorAlertIsPresenting.print("$errorAlertIsPresenting").removeDuplicates().first { $0 == true },
            sut.$errorAlertIsPresenting.dropFirst(),
            equals: true
        )
        
        sut.email = aProfile.email
        sut.password = "a password"
        
        if submitType.formType == .signUp {
            sut.userType = aProfile.userType
            sut.firstName = aProfile.firstName
            sut.lastName = aProfile.lastName
        }
        
        switch submitType {
        case .signUp:
            sut.signUp()
        case .signIn:
            sut.signIn()
        case .reauthenticate:
            sut.reauthenticate()
        }
        
        XCTAssertFalse(sut.emailInError)
        XCTAssertFalse(sut.passwordInError)
        
        if submitType.formType == .signUp {
            XCTAssertFalse(sut.userTypeInError)
            XCTAssertFalse(sut.firstNameInError)
            XCTAssertFalse(sut.lastNameInError)
        }

        wait(for: [expectation1, expectation2], timeout: 5)
        
        XCTAssertEqual(sut.errorAlertMessage, TestError.errorForTesting.rawValue)
    }

    func testGivenCorrectValuesEnteredInFormsOfEachType_WhenSubmitFail_ThenFormHaveErrors() {
        for submitType in SubmitType.allCases {
                        GivenCorrectValuesEnteredInForm_WhenSubmitFail_ThenFormHaveErrors(submitType: submitType)
        }
    }
}
