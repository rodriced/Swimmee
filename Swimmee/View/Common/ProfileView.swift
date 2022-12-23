//
//  ProfileView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 23/09/2022.
//

import SDWebImageSwiftUI
import SwiftUI

struct ProfileView: View {
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    @ObservedObject private var viewModel: ProfileViewModel

    @State private var deleteAccountVerificationViewIsPresented = false
    @State private var deleteAccountConfirmationIsPresented = false

    @State private var notImplementedAlertPresented = false

    init(viewModel: ProfileViewModel) {
        _viewModel = ObservedObject(initialValue: viewModel)
    }

    // MARK: - Photo components

    var photoField: some View {
        ZStack(alignment: verticalSizeClass == .compact ? .bottomLeading : .bottomTrailing) {
            Menu {
                photoActionsMenu
            } label: {
                photo
            }
            photoActionsMenuButton
                .offset(x: verticalSizeClass == .compact ? -10 : 10)
        }
    }

    var photo: some View {
        Group {
            switch viewModel.photoInfoEdited.state {
            case let .new(uiImage: pickedPhoto, data: _, size: _, hash: _):
                Image(uiImage: pickedPhoto)
                    .resizable()
                    .aspectRatio(contentMode: .fill)

            case .initial:
                if let photoUrl = viewModel.photoInfoEdited.initial?.url {
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
        Group {
            Button {
                viewModel.openPhotoPicker(.photoLibrary)
            } label: {
                Label("Photo from library", systemImage: "photo.on.rectangle")
            }
            Button {
                viewModel.openPhotoPicker(.camera)
            } label: {
                Label("Use camera", systemImage: "camera")
            }
            Button {
                viewModel.clearDisplayedPhoto()
            } label: {
                Label("Remove photo", systemImage: "trash")
            }
            .disabled(!viewModel.photoInfoEdited.isImagePresent)
        }
    }

    var photoActionsMenuButton: some View {
        Menu {
            photoActionsMenu
        } label: {
            Image(systemName: "square.and.pencil")
                .font(.system(.headline))
                .padding(5)
                .foregroundColor(.accentColor)
        }
    }

    // MARK: - Form submit components

    var updateProfileButton: some View {
        ButtonWithConfirmation(
            label: "Update",
            isDisabled: !viewModel.isReadyToSubmit,
            confirmationTitle: "Confirm your profile update.",
            confirmationButtonLabel: "Confirm Update"
        ) {
            viewModel.saveProfile()
            presentationMode.wrappedValue.dismiss()
        }
    }

    // MARK: - Delete account components

    var deleteAccountVerificationView: some View {
        ReauthenticationView(
            viewModel: SignSharedViewModel(formType: .signIn),
            message: "You must reauthenticate to confirm\nthe deletion of your account.",
            reauthenticationSuccess: $deleteAccountConfirmationIsPresented
        )
        .confirmationDialog("Confirme your account deletion", isPresented: $deleteAccountConfirmationIsPresented) {
            //                Button("Confirm deletion", role: .destructive, action: viewModel.deleteAccount)
            Button("Confirm deletion", role: .destructive) { notImplementedAlertPresented = true }
            Button("Cancel", role: .cancel) { deleteAccountVerificationViewIsPresented = false }
        } message: {
            Text("Your account is going to be deleted. Ok?")
        }
        .alert("Functionality not implemented", isPresented: $notImplementedAlertPresented) {
            Button("Return to profile") { deleteAccountVerificationViewIsPresented = false }
        }
    }

    var deleteAccountButton: some View {
        Button {
            deleteAccountVerificationViewIsPresented = true
        } label: {
            Text("Delete my account")
        }
        .foregroundColor(Color.red)
        .sheet(isPresented: $deleteAccountVerificationViewIsPresented) {
            deleteAccountVerificationView
        }
    }

    // MARK: - Layout organization

    var formPart1: some View {
        VStack {
            photoField

            Spacer()

            // User type indication
            HStack {
                Text("I'm a")
                Text("\(viewModel.initialProfile.userType.rawValue)").font(.headline)
            }
        }
    }

    var formPart2: some View {
        VStack(spacing: 5) {
            VStack {
                FormTextField(title: "First name", value: $viewModel.firstName, inError: viewModel.firstNameInError)
                    .textContentType(.givenName)
                FormTextField(title: "Last name", value: $viewModel.lastName, inError: viewModel.lastNameInError)
                    .textContentType(.familyName)
            }

            VStack {
                FormTextField(title: "Email", value: $viewModel.email, inError: viewModel.emailInError)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
            }

            Spacer()

            updateProfileButton

            Divider().overlay(Color.red).frame(height: 30)

            deleteAccountButton
        }
        .textFieldStyle(.roundedBorder)
    }

    var portraitView: some View {
        VStack {
            formPart1
            Spacer()
            formPart2
        }
    }

    var landscapeView: some View {
        HStack(spacing: 20) {
            formPart1
            formPart2
        }
    }

    var body: some View {
        VStack {
            if verticalSizeClass == .compact {
                landscapeView
            } else {
                portraitView
            }
        }
        .padding()
        .onTapGesture {
            hideKeyboard()
        }
        .navigationBarTitle("My profile")
        .sheet(isPresented: $viewModel.isPhotoPickerPresented) {
            ImagePicker(sourceType: viewModel.photoPickerImageSource, selectedImage: $viewModel.pickedPhoto)
        }
        .task { viewModel.startPublishers() }

        .navigationBarBackButtonHidden(viewModel.isReadyToSubmit)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                if viewModel.isReadyToSubmit {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                ProfileView(viewModel: ProfileViewModel(initialData: Profile.coachSample))
            }
            NavigationView {
                ProfileView(viewModel: ProfileViewModel(initialData: Profile.swimmerSample))
            }
        }
    }
}
