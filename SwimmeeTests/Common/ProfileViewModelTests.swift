//
//  ProfileViewModelTests.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 04/12/2022.
//

@testable import Swimmee

import Combine
import XCTest

final class ProfileViewModelTests: XCTestCase {
    private let aCoachProfile = Profile(userId: "", userType: .coach, firstName: "aFirstName", lastName: "aLastName", email: "an@e.mail")

    private var defaultMockImageStorageAPI: MockImageStorageAPI {
        let mockImageStorageAPI = MockImageStorageAPI()
        mockImageStorageAPI.mockUpload = { _, _ in URL(string: "https://an.url")! }
        mockImageStorageAPI.mockDelete = { _ in }
        return mockImageStorageAPI
    }

    private func profileViewModelSubmitSuccess(aProfile: Profile, imageStorageAPI: MockImageStorageAPI = MockImageStorageAPI(), accountAPI: AccountAPI = MockAccountAPI()) -> ProfileViewModel {
        let profileAPI = MockProfilePI()
        profileAPI.mockSave = { _ in }

        let config = ProfileViewModel.Config(
            profileAPI: profileAPI,
            imageStorage: imageStorageAPI,
            accountAPI: accountAPI,
            debounceDelay: 0
        )

        return ProfileViewModel(initialData: aProfile, config: config)
    }

//    private func profileViewModelSubmitFail(aProfile: Profile) -> ProfileViewModel {
//        let profileAPI = MockProfilePI()
//        profileAPI.mockSave = { _ in throw TestError.errorForTesting }
//
//        let config = ProfileViewModel.Config(
//            profileAPI: profileAPI,
//            imageStorage: defaultMockImageStorageAPI,
//            accountAPI: MockAccountAPI(),
//            debounceDelay: 0
//        )
//
//        return ProfileViewModel(initialData: aProfile, config: config)
//    }

    func testGivenNewForm_WhenNoAction_ThenFormHaveNoErrorAndProfileDataInFields() {
        let aProfile = Profile.coachSample

        let sut = profileViewModelSubmitSuccess(aProfile: aProfile)
        sut.startPublishers()

        XCTAssertEqual(sut.firstName, aProfile.firstName)
        XCTAssertEqual(sut.lastName, aProfile.lastName)
        XCTAssertEqual(sut.email, aProfile.email)

        XCTAssertFalse(sut.firstNameInError)
        XCTAssertFalse(sut.lastNameInError)
        XCTAssertFalse(sut.emailInError)

        XCTAssertFalse(sut.isReadyToSubmit)
    }

    func testGivenAFieldModifiedWithACorrectValue_WhenSubmitedWithSuccess_ThenFormHaveNoErrorAndProfileDataInFields3() {
        let aProfile = Profile.coachSample

        let sut = profileViewModelSubmitSuccess(aProfile: aProfile)
        sut.startPublishers()

        assertPublishedValue(
            sut.$isReadyToSubmit, equals: true
        ) {
            sut.firstName = aProfile.firstName + "adding"
        }

//        print(sut.firstName, sut.lastName, sut.email, sut.photoInfoEdited.state)

        assertPublishedValue(
            sut.$isReadyToSubmit, equals: false
        ) {
            sut.firstName = aProfile.firstName
        }

        assertPublishedValue(
            sut.$isReadyToSubmit, equals: true
        ) {
            sut.lastName = aProfile.lastName + "adding"
        }

        sut.saveProfile()
    }

    func testGivenAProfileForm_WhenFieldModifiedWithIncorrectValue_ThenFieldIsInErrorOnlyAndFormNotReadyToSubmit() {
        let aProfile = Profile.coachSample

        let sut = profileViewModelSubmitSuccess(aProfile: aProfile)
        sut.startPublishers()

        assertPublishedValue(
            Publishers.CombineLatest(sut.$isReadyToSubmit, sut.$emailInError)
                .map(String.init(describing:)), // To make tuple "Equatable"
            equals: "(false, false)"
        ) {
//            print("--> Will modify : \(sut.email)")
            sut.email = "bad email"
        }
    }

    func testOpenPhotoPicker() {
        let aProfile = aCoachProfile

        let sut = profileViewModelSubmitSuccess(aProfile: aProfile)
        sut.startPublishers()

        XCTAssertFalse(sut.isPhotoPickerPresented)

        sut.openPhotoPicker(.camera)
        XCTAssertTrue(sut.isPhotoPickerPresented)
    }

    func testGivenAProfileFormWithNoPhoto_WhenPhotoIsPicked_ThenPhotoInfoEditedIsUpdated() {
        let expectation = expectation(description: "Waiting for save photo")

        var aProfile = aCoachProfile
        aProfile.photoInfo = nil

        let imageStorageAPI = MockImageStorageAPI()
        imageStorageAPI.mockUpload = { name, data in
            XCTAssertEqual(name, aProfile.userId)
            XCTAssertEqual(data, Samples.aPngImage)
            expectation.fulfill()
            return URL(string: "https://an.url")!
        }

        let sut = profileViewModelSubmitSuccess(aProfile: aProfile, imageStorageAPI: imageStorageAPI)
        sut.startPublishers()

        XCTAssertNil(sut.initialProfile.photoInfo)
        XCTAssertNil(sut.pickedPhoto)
        XCTAssertEqual(sut.photoInfoEdited.state, .initial)

        sut.pickedPhoto = Samples.anUIImage

        let newState = PhotoInfoEdited.State.new(uiImage: Samples.anUIImage, data: Samples.aPngImage, size: Samples.aPngImage.count, hash: Samples.aPngImage.hashValue)

        XCTAssertEqual(sut.photoInfoEdited.state, newState)
        
        sut.saveProfile()
        
        wait(for: [expectation], timeout: 1)
    }

    func testGivenAProfileFormWithAPhoto_WhenPhotoIsRemoved_ThenPhotoInfoEditedIsUpdated() {
        let expectation = expectation(description: "Waiting for delete photo")
        
        var aProfile = aCoachProfile
        aProfile.photoInfo = Samples.aPhotoInfo

        let imageStorageAPI = MockImageStorageAPI()
        imageStorageAPI.mockDelete = { name in
            XCTAssertEqual(name, aProfile.userId)
            expectation.fulfill()
        }

        let sut = profileViewModelSubmitSuccess(aProfile: aProfile, imageStorageAPI: imageStorageAPI)
        sut.startPublishers()

        XCTAssertEqual(sut.initialProfile.photoInfo, Samples.aPhotoInfo)
        XCTAssertNil(sut.pickedPhoto)
        XCTAssertEqual(sut.photoInfoEdited.state, .initial)

        sut.clearDisplayedPhoto()

        XCTAssertEqual(sut.photoInfoEdited.state, .removed)
        
        sut.saveProfile()
        
        wait(for: [expectation], timeout: 1)
    }

    func testWhenDeleteAccountIsAsked_ThenAccountAPIIsCalled() {
        let expectation = expectation(description: "Waiting for delete account API call")

        let aProfile = aCoachProfile

        let accountAPI = MockAccountAPI()
        accountAPI.mockDeleteCurrrentAccount = { expectation.fulfill() }

        let config = ProfileViewModel.Config(
            profileAPI: MockProfilePI(),
            imageStorage: defaultMockImageStorageAPI,
            accountAPI: accountAPI,
            debounceDelay: 0
        )

        let sut = ProfileViewModel(initialData: aProfile, config: config)
        sut.startPublishers()

        sut.deleteAccount()

        wait(for: [expectation], timeout: 1)
    }

    func testGivenAProfileFormWithAPhoto_WhenFormIsModifiedAndSaved_ThenPhotoIsNotRemoved() {
        var aProfile = aCoachProfile
        aProfile.photoInfo = Samples.aPhotoInfo

        let initialPhotoInfoEdited = PhotoInfoEdited(Samples.aPhotoInfo, imageStorage: defaultMockImageStorageAPI)

        let profileAPI = MockProfilePI()
        profileAPI.mockSave = { profileToSave in
            XCTAssertNotNil(profileToSave.photoInfo)
        }

        let config = ProfileViewModel.Config(
            profileAPI: profileAPI,
            imageStorage: defaultMockImageStorageAPI,
            accountAPI: MockAccountAPI(),
            debounceDelay: 0
        )

        let sut = ProfileViewModel(initialData: aProfile, config: config)
        sut.startPublishers()

        assertPublishedValue(
            sut.$isReadyToSubmit, equals: true
        ) {
            sut.lastName = aProfile.lastName + "adding"
        }

        XCTAssertEqual(sut.photoInfoEdited.state, initialPhotoInfoEdited.state)

        sut.saveProfile()
    }
    
    func testGivenAProfileForm_WhenEmailIsModifiedAndFormSubmited_ThenEmailIsUpdated() {
        let expectation = expectation(description: "Waiting for updated Email")

        var aProfile = aCoachProfile
        var newEmail = "updated@with.new.email"

        let accountAPI = MockAccountAPI()
        accountAPI.mockUpdateEmail = {email in
            XCTAssertEqual(email, newEmail)
            expectation.fulfill()
        }
        let sut = profileViewModelSubmitSuccess(aProfile: aProfile, accountAPI: accountAPI)
        sut.startPublishers()

        assertPublishedValue(
            sut.$isReadyToSubmit, equals: true
        ) {
            sut.email = newEmail
        }
        
        sut.saveProfile()
        
        wait(for: [expectation], timeout: 1)
    }

    func testGivenAProfileForm_WhenEmailIsModifiedAndFormSubmitedWithNetworkError_ThenAlertIsTriggered() {
        var aProfile = aCoachProfile
        var newEmail = "updated@with.new.email"

        let accountAPI = MockAccountAPI()
        accountAPI.mockUpdateEmail = {email in
            throw TestError.fakeNetworkError
        }

        let sut = profileViewModelSubmitSuccess(aProfile: aProfile, accountAPI: accountAPI)
        sut.startPublishers()

        assertPublishedValue(
            sut.$isReadyToSubmit, equals: true
        ) {
            sut.email = newEmail
        }
                        
        assertPublishedValue(
            sut.alertContext.$isPresented, equals: true
        ) {
            sut.saveProfile()
        }

        XCTAssertEqual(sut.alertContext.message, "fakeNetworkError")
    }

}
