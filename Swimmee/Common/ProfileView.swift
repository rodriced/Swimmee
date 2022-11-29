//
//  ProfileView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 23/09/2022.
//

import Combine
import SDWebImageSwiftUI
import SwiftUI

class ProfileViewModel: LoadableViewModelV2 {
    // MARK: Form view properties

    var initialProfile: Profile

    @Published var firstName: String
    @Published var lastName: String
    @Published var email: String
    @Published var firstNameInError = false
    @Published var lastNameInError = false
    @Published var emailInError = false

    // You must not interact with photo directly. Use photoInfoEdited.update instead. (They are linked with publisher assign)
    @Published var photo = PhotoInfoEdited.State.initial
    var photoInfoEdited: PhotoInfoEdited

    @Published var isPhotoPickerPresented = false
    var photoPickeImageSource = UIImagePickerController.SourceType.photoLibrary
    @Published var pickedPhoto: UIImage? = nil {
        didSet {
            guard let pickedPhoto else { return }

            photoInfoEdited.updateWith(uiImage: pickedPhoto)
        }
    }

    @Published var authenticationSheet = false
    @Published var confirmationActionSheet = false

    @Published var isReadyToSubmitUpdate: Bool = false

    // MARK: Protocol LoadableViewModelV2 implementation

    required init(initialData: Profile) {
        debugPrint("---- ProfileViewModel.init")

        self.initialProfile = initialData
        self.firstName = initialData.firstName
        self.lastName = initialData.lastName
        self.email = initialData.email

        self.photoInfoEdited = PhotoInfoEdited(initialData.photo)
    }

    func refreshedLoadedData(_ loadedData: Profile) {}
    var restartLoader: (() -> Void)?

    // MARK: Debug

    deinit {
        debugPrint("---- ProfileViewModel deinit")
    }

    // MARK: Form validation model

    lazy var firstNameField = FormField(publishedValue: &_firstName,
                                        validate: ValueValidation.validateFirstName,
                                        initialValue: initialProfile.firstName)

    lazy var lastNameField = FormField(publishedValue: &_lastName,
                                       validate: ValueValidation.validateLastName,
                                       initialValue: initialProfile.lastName)

    lazy var emailField = FormField(publishedValue: &_email,
                                    validate: ValueValidation.validateEmail,
                                    initialValue: initialProfile.email)

    lazy var photoField = FormField(publishedValue: &_photo,
                                    // TODO: Must fix link bug between photoInfoEdited.state and photo (State of Update button don't return to its initial state when we do the same with photo)
                                    // BUT SEEMS OK NOW. TO BE VERIFIED
                                    compareWith: { $0 != .initial },
                                    debounceDelay: 0)

    // MARK: Form validation logic

    lazy var formPublishers: [any ConnectablePublisher] =
        [firstNameField.publisher, lastNameField.publisher, emailField.publisher, photoField.publisher]

    lazy var formModified =
        [firstNameField.modified, lastNameField.modified, emailField.modified, photoField.modified]
            .combineLatest()
            .map { $0.contains(true) }

    lazy var formValidated =
        [firstNameField.validated, lastNameField.validated, emailField.validated, photoField.validated]
            .combineLatest()
            .map { $0.allSatisfy { $0 } }

    lazy var formReadyToSubmitUpdate =
        Publishers.CombineLatest(formModified, formValidated)
            .map { $0 == (true, true) }

    var cancellables = Set<AnyCancellable>()

    func startPublishers() {
        photoInfoEdited.$state.assign(to: &$photo)

        formReadyToSubmitUpdate
            .assign(to: &$isReadyToSubmitUpdate)

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
        photoPickeImageSource = source
    }

    func clearDisplayedPhoto() {
        pickedPhoto = nil
        photoInfoEdited.updateWith(uiImage: nil)
    }

    func saveProfile() {
        Task {
            let photoInfo = await photoInfoEdited.save(as: initialProfile.userId)

            let profile = {
                var profile = initialProfile
                profile.firstName = firstName
                profile.lastName = lastName
                profile.email = email
                profile.photo = photoInfo
                return profile
            }()

            try? await API.shared.profile.save(profile)
        }
    }

    func deleteAccount() {
        // TODO: Implement this with Firebase function
        // To test. Blocking main thread to prevent ececution of swiftui ui update until account deletion (photo, profile, auth user) completion to prevent inconsistent state
        _ = DispatchQueue.main.sync {
            Task {
                try await FirebaseAccountManager().deleteCurrrentAccount()
            }
        }
    }
}

struct ProfileView: View {
    @Environment(\.presentationMode) private var presentationMode

    @ObservedObject var vm: ProfileViewModel

    init(vm: ProfileViewModel) {
        debugPrint("---- ProfileView created")
        _vm = ObservedObject(initialValue: vm)
    }

    var profilePhoto: some View {
        Group {
            switch vm.photo {
            case let .new(uiImage: pickedPhoto, data: _, size: _, hash: _):
                Image(uiImage: pickedPhoto)
                    .resizable()
                    .aspectRatio(contentMode: .fill)

            case .initial:
                if let photoUrl = vm.photoInfoEdited.initial?.url {
                    WebImage(url: photoUrl)
                        .resizable()
                        .placeholder(Image("UserPhotoPlaceholder"))
                        .scaledToFill()

                } else {
                    Image("UserPhotoPlaceholder")
                        .resizable()
                }

            case .removed:
                Image("UserPhotoPlaceholder")
                    .resizable()
            }
        }
        .frame(width: 200, height: 200)
        .clipShape(Circle())
        .overlay(Circle().stroke(.blue.opacity(0.5), lineWidth: 4))
        .shadow(radius: 6)
    }

    var photoActionsMenu: some View {
        Image(systemName: "square.and.pencil")
            .font(.system(.headline))
            .padding(5)
            .foregroundColor(.accentColor)
            .contextMenu {
                Button {
                    vm.openPhotoPicker(.photoLibrary)
                } label: {
                    Label("Choose from library", systemImage: "photo.on.rectangle")
                }
                Button {
                    vm.openPhotoPicker(.camera)
                } label: {
                    Label("Use camera", systemImage: "camera")
                }
                Button {
                    vm.clearDisplayedPhoto()
                } label: {
                    Label("Remove photo", systemImage: "trash")
                }
            }
    }

    var deleteAccountButton: some View {
        Button {
            vm.authenticationSheet = true
        } label: {
            Text("Delete my account")
        }
        .foregroundColor(Color.red)
        .sheet(isPresented: $vm.authenticationSheet) {
            AuthenticationView(viewModel: SignSharedViewModel(formType: .signIn, submitSuccess: $vm.confirmationActionSheet)
            )
            .actionSheet(isPresented: $vm.confirmationActionSheet) {
                ActionSheet(title: Text("Confirm your account deletion"), message: nil, buttons: [
                    .destructive(Text("Delete"), action: {
                        vm.deleteAccount()
                    }),
                    .cancel()
                ])
            }
        }
    }

    var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                profilePhoto
                photoActionsMenu
                    .offset(x: 10)
            }

            Spacer()

            HStack {
                Text("I'm a")
                Text("\(vm.initialProfile.userType.rawValue)").font(.headline)
            }
            Spacer()

            VStack(spacing: 30) {
                VStack {
                    FormTextField(title: "First name", value: $vm.firstName, inError: vm.firstNameInError)
                    FormTextField(title: "Last name", value: $vm.lastName, inError: vm.lastNameInError)
                }

                VStack {
                    FormTextField(title: "Email", value: $vm.email, inError: vm.emailInError)
                }
            }
            .textFieldStyle(.roundedBorder)

            Spacer()

            Button {
                vm.saveProfile()
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Update").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!vm.isReadyToSubmitUpdate)

//            .keyboardShortcut(.defaultAction)

            Divider().overlay(Color.red).frame(height: 30)
//                .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))

            deleteAccountButton
        }
        .navigationTitle("My profile")
        .padding()
        .sheet(isPresented: $vm.isPhotoPickerPresented) {
            ImagePicker(sourceType: vm.photoPickeImageSource, selectedImage: $vm.pickedPhoto)
        }
        .task { vm.startPublishers() }
    }
}

// struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            ProfileView(vm: ProfileViewModel(profile: Profile.coachSample))
//        }
//    }
// }
