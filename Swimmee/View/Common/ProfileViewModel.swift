//
//  ProfileViewModel.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 04/12/2022.
//

import Combine
import UIKit

class ProfileViewModel: LoadableViewModel {
    struct Config: ViewModelConfig {
        let saveProfie: (Profile) async throws -> Void
        let deleteCurrrentAccount: () async throws -> Void
        let imageStorage: ImageStorageAPI
        let debounceDelay: RunLoop.SchedulerTimeType.Stride

        static let `default` =
            Config(saveProfie: API.shared.profile.save,
                   deleteCurrrentAccount: API.shared.account.deleteCurrrentAccount,
                   imageStorage: API.shared.imageStorage,
                   debounceDelay: 0.5)
    }

    let config: Config

    // MARK: Form view properties

    let initialProfile: Profile

    @Published var firstName: String
    @Published var lastName: String
    @Published var email: String
    @Published var firstNameInError = false
    @Published var lastNameInError = false
    @Published var emailInError = false

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
    @Published var updateProfileConfirmationIsPresented = false

    @Published var reauthenticationViewIsPresented = false
    @Published var deleteAccountConfirmationIsPresented = false

    // MARK: Protocol LoadableViewModel implementation

    required init(initialData: Profile, config: Config = .default) {
        debugPrint("---- ProfileViewModel.init")

        self.config = config

        self.initialProfile = initialData
        self.firstName = initialData.firstName
        self.lastName = initialData.lastName
        self.email = initialData.email

        self.photoInfoEdited = PhotoInfoEdited(initialData.photoInfo,
                                               imageStorage: config.imageStorage)
    }

    func refreshedLoadedData(_ loadedData: Profile) {}
    var restartLoader: (() -> Void)?

    // MARK: Debug

    deinit {
        debugPrint("---- ProfileViewModel deinit")
    }

    // MARK: Form validation model

    private lazy var firstNameField = FormField(valuePublisher: $firstName,
                                                validate: ValueValidation.validateFirstName,
                                                initialValue: initialProfile.firstName,
                                                debounceDelay: config.debounceDelay)

    private lazy var lastNameField = FormField(valuePublisher: $lastName,
                                               validate: ValueValidation.validateLastName,
                                               initialValue: initialProfile.lastName,
                                               debounceDelay: config.debounceDelay)

    private lazy var emailField = FormField(valuePublisher: $email,
                                            validate: ValueValidation.validateEmail,
                                            initialValue: initialProfile.email,
                                            debounceDelay: config.debounceDelay)

    private lazy var photoInfoField = FormField(valuePublisher: photoInfoEdited.$state,
                                                // TODO: Must fix link bug between photoInfoEdited.state and readOnlyPhotoInfoEditedState (State of Update button don't return to its initial state when we do the same with photo)
                                                // BUT SEEMS OK NOW. TO BE VERIFIED
                                                compareWith: { $0 != .initial },
                                                debounceDelay: 0)

    // MARK: Form validation logic

    private lazy var formPublishers: [any ConnectablePublisher] =
        [firstNameField.publisher, lastNameField.publisher, emailField.publisher, photoInfoField.publisher]

    private lazy var formModified =
        [firstNameField.modified, lastNameField.modified, emailField.modified, photoInfoField.modified]
            .combineLatest()
            .map { $0.contains(true) }

    private lazy var formValidated =
        [firstNameField.validated, lastNameField.validated, emailField.validated, photoInfoField.validated]
            .combineLatest()
            .map { $0.allSatisfy { $0 } }

    private lazy var formReadyToSubmit =
        Publishers.CombineLatest(formModified, formValidated)
            .map { $0 == (true, true) }

    private var cancellables = Set<AnyCancellable>()

    func startPublishers() {
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
            var profile = initialProfile
            profile.firstName = firstName
            profile.lastName = lastName
            profile.email = email
            
            if photoInfoEdited.state != .initial {
                profile.photoInfo = await photoInfoEdited.save(as: initialProfile.userId)
            }

            try? await config.saveProfie(profile)
        }
    }

    func deleteAccount() {
        // TODO: Implement this with Firebase function
        // To be tested. Blocking main thread to prevent ececution of swiftui ui update until account deletion (photo, profile, auth user) completion to prevent inconsistent state
        Task {
            do {
                try await config.deleteCurrrentAccount()
            } catch {
                print("API.shared.account.deleteCurrrentAccount error catched : \(error.localizedDescription)")
            }
        }
    }
}