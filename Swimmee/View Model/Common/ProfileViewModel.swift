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
        // Injected API
        let saveProfie: (Profile) async throws -> Void
        let deleteCurrrentAccount: () async throws -> Void
        let imageStorage: ImageStorageAPI

        // Time interval between user input ending and validation launching
        let debounceDelay: RunLoop.SchedulerTimeType.Stride

        static let `default` =
            Config(saveProfie: API.shared.profile.save,
                   deleteCurrrentAccount: API.shared.account.deleteCurrrentAccount,
                   imageStorage: API.shared.imageStorage,
                   debounceDelay: 0.5)
    }

    let config: Config

    // MARK: - Form view properties

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

    // MARK: - Protocol LoadableViewModel implementation

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

    // MARK: - Form fields validation status

    private lazy var firstNameStatus = FieldStatus(valuePublisher: $firstName,
                                                   validate: ValueValidation.validateFirstName,
                                                   initialValue: initialProfile.firstName,
                                                   debounceDelay: config.debounceDelay)

    private lazy var lastNameStatus = FieldStatus(valuePublisher: $lastName,
                                                  validate: ValueValidation.validateLastName,
                                                  initialValue: initialProfile.lastName,
                                                  debounceDelay: config.debounceDelay)

    private lazy var emailStatus = FieldStatus(valuePublisher: $email,
                                               validate: ValueValidation.validateEmail,
                                               initialValue: initialProfile.email,
                                               debounceDelay: config.debounceDelay)

    private lazy var photoStatus = FieldStatus(valuePublisher: photoInfoEdited.$state,
                                               compareWith: { $0 != .initial },
                                               debounceDelay: 0)

    // MARK: - Form validation logic

    private lazy var formModified =
        [firstNameStatus.modified, lastNameStatus.modified, emailStatus.modified, photoStatus.modified]
            .combineLatest()
            .map { $0.contains(true) }

    private lazy var formValidated =
        [firstNameStatus.validated, lastNameStatus.validated, emailStatus.validated, photoStatus.validated]
            .combineLatest()
            .map { $0.allSatisfy { $0 } }

    private lazy var formReadyToSubmit =
        Publishers.CombineLatest(formModified, formValidated)
            .map { $0 == (true, true) }

    private var cancellables = Set<AnyCancellable>()

    func startPublishers() {
        formReadyToSubmit
            .assign(to: &$isReadyToSubmit)

        firstNameStatus.validated.not().assign(to: &$firstNameInError)
        lastNameStatus.validated.not().assign(to: &$lastNameInError)
        emailStatus.validated.not().assign(to: &$emailInError)

        let fieldsStatusPublishers: [any ConnectablePublisher] =
            [firstNameStatus.publisher, lastNameStatus.publisher, emailStatus.publisher, photoStatus.publisher]

        fieldsStatusPublishers
            .forEach {
                $0.connect().store(in: &cancellables)
            }
    }

    // MARK: - Form actions

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