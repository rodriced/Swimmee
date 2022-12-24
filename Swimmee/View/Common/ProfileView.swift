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
    private func dismiss() { presentationMode.wrappedValue.dismiss() }

    @Environment(\.verticalSizeClass) private var verticalSizeClass

    @ObservedObject private var viewModel: ProfileViewModel

    @State private var reauthenticationViewIsPresented = false
    @State private var deleteAccountViewIsPresented = false

    init(viewModel: ProfileViewModel) {
        _viewModel = ObservedObject(initialValue: viewModel)
    }

    // MARK: - Photo components

    private var photoField: some View {
        ZStack(alignment: verticalSizeClass == .compact ? .bottomLeading : .bottomTrailing) {
            // Photo action menu will open when you tap on the dedicated button or on the photo itself
            Menu {
                photoActionsMenu
            } label: {
                photo
            }
            photoActionsMenuButton
                .offset(x: verticalSizeClass == .compact ? -10 : 10)
        }
    }

    private var photo: some View {
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

    private var photoActionsMenu: some View {
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

    private var photoActionsMenuButton: some View {
        Menu {
            photoActionsMenu
        } label: {
            Image(systemName: "square.and.pencil")
                .font(.system(.headline))
                .padding(5)
                .foregroundColor(.accentColor)
        }
    }

    // MARK: - Button components
    
    var reauthenticationView: some View {
        ReauthenticationView(
            title: "Profile Update",
            message: "you are going to save a new email.\n\nYou must reauthenticate\nto update your profile.",
            emailTitle: "Enter your old email",
            buttonLabel: "Confirm Update",
            successCompletion: {
                viewModel.saveProfile()
                dismiss()
            }
        )
    }
    
    private var updateProfileButton: some View {
        Group {
            if viewModel.emailIsModified {
                Button {
                    reauthenticationViewIsPresented = true
                } label: {
//                    Text("Update")
                    Label("Update", systemImage: "key.viewfinder")
                        .frame(maxWidth: .infinity)
                }
                .disabled(!viewModel.isReadyToSubmit)
                .buttonStyle(.borderedProminent)
                .sheet(isPresented: $reauthenticationViewIsPresented) {
                    reauthenticationView
                }

            } else {
                ButtonWithConfirmation(
                    label: "Update",
                    isDisabled: !viewModel.isReadyToSubmit,
                    confirmationTitle: "Confirm your profile update.",
                    confirmationButtonLabel: "Confirm Update"
                ) {
                    viewModel.saveProfile()
                    dismiss()
                }
            }
        }
    }

    private var deleteAccountButton: some View {
        Button {
            deleteAccountViewIsPresented = true
        } label: {
            Text("Delete my account")
        }
        .foregroundColor(Color.red)
        .sheet(isPresented: $deleteAccountViewIsPresented) {
            DeleteAccountView(cancelCompletion: { deleteAccountViewIsPresented = false })
//            DeleteAccountView(cancelCompletion: {})
        }
    }

    // MARK: - Layout organization

    private var formPart1: some View {
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

    private var formPart2: some View {
        VStack(spacing: 5) {
            VStack {
                FormTextField("First name", value: $viewModel.firstName, inError: viewModel.firstNameInError)
                    .textContentType(.givenName)
                FormTextField("Last name", value: $viewModel.lastName, inError: viewModel.lastNameInError)
                    .textContentType(.familyName)
            }

            VStack {
                FormTextField("Email", value: $viewModel.email, inError: viewModel.emailInError)
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

    private var portraitView: some View {
        VStack {
            formPart1
            Spacer()
            formPart2
        }
    }

    private var landscapeView: some View {
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
                    Button("Cancel", action: dismiss)
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
