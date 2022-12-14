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
        mockImageStorageAPI.mockUpload = { URL(string: "https://an.url")! }
        mockImageStorageAPI.mockDelete = {}
        return mockImageStorageAPI
    }

    private func profileViewModelSubmitSuccess(aProfile: Profile) -> ProfileViewModel {
        let config = ProfileViewModel.Config(
            saveProfie: { _ in },
            deleteCurrrentAccount: {},
            imageStorage: defaultMockImageStorageAPI,
            debounceDelay: 0
        )

        return ProfileViewModel(initialData: aProfile, config: config)
    }

    private func profileViewModelSubmitFail(aProfile: Profile) -> ProfileViewModel {
        let config = ProfileViewModel.Config(
            saveProfie: { _ in throw TestError.errorForTesting },
            deleteCurrrentAccount: {},
            imageStorage: defaultMockImageStorageAPI,
            debounceDelay: 0
        )

        return ProfileViewModel(initialData: aProfile, config: config)
    }

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

    func testGivenAFieldModifiedWithIncorrectValue_WhenSubmited_ThenFieldIsInErrorOnlyAfterSubmit() {
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

        assertPublishedValue(
            sut.$emailInError, equals: false
        ) {
//            print("--> Will saveProfile")
            sut.saveProfile()
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
        var aProfile = aCoachProfile
        aProfile.photoInfo = nil

        let sut = profileViewModelSubmitSuccess(aProfile: aProfile)
        sut.startPublishers()

        XCTAssertNil(sut.initialProfile.photoInfo)
        XCTAssertNil(sut.pickedPhoto)
        XCTAssertEqual(sut.photoInfoEdited.state, .initial)

        sut.pickedPhoto = Samples.anUIImage

        let newState = PhotoInfoEdited.State.new(uiImage: Samples.anUIImage, data: Samples.aPngImage, size: Samples.aPngImage.count, hash: Samples.aPngImage.hashValue)

        XCTAssertEqual(sut.photoInfoEdited.state, newState)
    }

    func testGivenAProfileFormWithAPhoto_WhenPhotoIsRemoved_ThenPhotoInfoEditedIsUpdated() {
        var aProfile = aCoachProfile
        aProfile.photoInfo = Samples.aPhotoInfo

        let sut = profileViewModelSubmitSuccess(aProfile: aProfile)
        sut.startPublishers()

        XCTAssertEqual(sut.initialProfile.photoInfo, Samples.aPhotoInfo)
        XCTAssertNil(sut.pickedPhoto)
        XCTAssertEqual(sut.photoInfoEdited.state, .initial)

        sut.clearDisplayedPhoto()

        XCTAssertEqual(sut.photoInfoEdited.state, .removed)
    }

    func testWhenDeleteAccountIsAsked_ThenAccountAPIIsCalled() {
        let expectation = expectation(description: "Waiting for delete account API call")

        let aProfile = aCoachProfile

        let config = ProfileViewModel.Config(
            saveProfie: { _ in },
            deleteCurrrentAccount: { expectation.fulfill() },
            imageStorage: defaultMockImageStorageAPI,
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

        let config = ProfileViewModel.Config(
            saveProfie: { profileToSave in
                XCTAssertNotNil(profileToSave.photoInfo)
            },
            deleteCurrrentAccount: {},
            imageStorage: defaultMockImageStorageAPI,
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
}
