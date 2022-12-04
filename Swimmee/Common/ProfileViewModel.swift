//
//  ProfileViewModel.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 04/12/2022.
//

import Combine
import UIKit

class ProfileViewModel: LoadableViewModel {
    // MARK: Form view properties

    let initialProfile: Profile

    @Published var firstName: String
    @Published var lastName: String
    @Published var email: String
    @Published var firstNameInError = false
    @Published var lastNameInError = false
    @Published var emailInError = false

    // You must not interact with readOnlyPhotoInfoEditedState directly. Use photoInfoEdited.update instead. (They are linked with publisher assign)
    @Published private(set) var readOnlyPhotoInfoEditedState = PhotoInfoEdited.State.initial
    let photoInfoEdited: PhotoInfoEdited

    @Published var isPhotoPickerPresented = false
    private(set) var photoPickerImageSource = UIImagePickerController.SourceType.photoLibrary
    @Published var pickedPhoto: UIImage? = nil {
        didSet {
            guard let pickedPhoto else { return }

            photoInfoEdited.updateWith(uiImage: pickedPhoto)
        }
    }

    @Published var isReadyToSubmit: Bool = false
    @Published var updateProfileConfirmationDialogIsPresented = false

    @Published var reauthenticationViewIsPresented = false
    @Published var deleteAccountConfirmationDialogIsPresented = false

    // MARK: Protocol LoadableViewModel implementation

    required init(initialData: Profile) {
        debugPrint("---- ProfileViewModel.init")

        self.initialProfile = initialData
        self.firstName = initialData.firstName
        self.lastName = initialData.lastName
        self.email = initialData.email

        self.photoInfoEdited = PhotoInfoEdited(initialData.photoInfo)
    }

    func refreshedLoadedData(_ loadedData: Profile) {}
    var restartLoader: (() -> Void)?

    // MARK: Debug

    deinit {
        debugPrint("---- ProfileViewModel deinit")
    }

    // MARK: Form validation model

    lazy private var firstNameField = FormField(publishedValue: &_firstName,
                                        validate: ValueValidation.validateFirstName,
                                        initialValue: initialProfile.firstName)

    lazy private var lastNameField = FormField(publishedValue: &_lastName,
                                       validate: ValueValidation.validateLastName,
                                       initialValue: initialProfile.lastName)

    lazy private var emailField = FormField(publishedValue: &_email,
                                    validate: ValueValidation.validateEmail,
                                    initialValue: initialProfile.email)

    lazy private var photoInfoField = FormField(publishedValue: &_readOnlyPhotoInfoEditedState,
                                        // TODO: Must fix link bug between photoInfoEdited.state and readOnlyPhotoInfoEditedState (State of Update button don't return to its initial state when we do the same with photo)
                                        // BUT SEEMS OK NOW. TO BE VERIFIED
                                        compareWith: { $0 != .initial },
                                        debounceDelay: 0)

    // MARK: Form validation logic

    lazy private var formPublishers: [any ConnectablePublisher] =
        [firstNameField.publisher, lastNameField.publisher, emailField.publisher, photoInfoField.publisher]

    lazy private var formModified =
        [firstNameField.modified, lastNameField.modified, emailField.modified, photoInfoField.modified]
            .combineLatest()
            .map { $0.contains(true) }

    lazy private var formValidated =
        [firstNameField.validated, lastNameField.validated, emailField.validated, photoInfoField.validated]
            .combineLatest()
            .map { $0.allSatisfy { $0 } }

    lazy private var formReadyToSubmit =
        Publishers.CombineLatest(formModified, formValidated)
            .map { $0 == (true, true) }

    private var cancellables = Set<AnyCancellable>()

    func startPublishers() {
        photoInfoEdited.$state.assign(to: &$readOnlyPhotoInfoEditedState)

        formReadyToSubmit
            .assign(to: &$isReadyToSubmit)

        firstNameField.validated.not().assign(to: &$firstNameInError)
        lastNameField.validated.not().assign(to: &$lastNameInError)
        emailField.validated.not().assign(to: &$emailInError)

        formPublishers.forEach {
            $0.connect().store(in: &cancellables)
        }
    }

    // MARK: Form actions

    func openPhotoPicker(_ source: UIImagePickerController.SourceType) {
        isPhotoPickerPresented = true
        photoPickerImageSource = source
    }

    func clearDisplayedPhoto() {
        pickedPhoto = nil
        photoInfoEdited.updateWith(uiImage: nil)
    }

    func saveProfile() {
        Task {
            let newPhotoInfo = await photoInfoEdited.save(as: initialProfile.userId)

            let profile = {
                var profile = initialProfile
                profile.firstName = firstName
                profile.lastName = lastName
                profile.email = email
                profile.photoInfo = newPhotoInfo
                return profile
            }()

            try? await API.shared.profile.save(profile)
        }
    }

    func deleteAccount() {
        // TODO: Implement this with Firebase function
        // To be tested. Blocking main thread to prevent ececution of swiftui ui update until account deletion (photo, profile, auth user) completion to prevent inconsistent state
        Task {
            do {
                try await API.shared.account.deleteCurrrentAccount()
            } catch {
                print("API.shared.account.deleteCurrrentAccount error catched : \(error.localizedDescription)")
            }
        }
    }
}
