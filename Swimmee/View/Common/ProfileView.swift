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
    @Environment(\.verticalSizeClass) var verticalSizeClass

    @ObservedObject var viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
//        debugPrint("---- ProfileView created")
        _viewModel = ObservedObject(initialValue: viewModel)
    }

    var profilePhoto: some View {
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

    var updateProfileButton: some View {
        Button {
            viewModel.updateProfileConfirmationIsPresented = true
        } label: {
            Text("Update").frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .disabled(!viewModel.isReadyToSubmit)
        .confirmationDialog("Confirm your profile update.", isPresented: $viewModel.updateProfileConfirmationIsPresented) {
            Button("Confirm update") {
                viewModel.saveProfile()
                presentationMode.wrappedValue.dismiss()
            }
        }
        .keyboardShortcut(.defaultAction)
    }

    var deleteAccountButton: some View {
        Button {
            viewModel.reauthenticationViewIsPresented = true
        } label: {
            Text("Delete my account")
        }
        .foregroundColor(Color.red)
        .sheet(isPresented: $viewModel.reauthenticationViewIsPresented) {
            ReauthenticationView(
                viewModel: SignSharedViewModel(formType: .signIn),
                message: "You must reauthenticate to confirm\nthe deletion of your account.",
                reauthenticationSuccess: $viewModel.deleteAccountConfirmationIsPresented
            )
            .confirmationDialog("Confirme your account deletion", isPresented: $viewModel.deleteAccountConfirmationIsPresented) {
                Button("Confirm deletion", role: .destructive, action: viewModel.deleteAccount)
                Button("Cancel", role: .cancel) { viewModel.reauthenticationViewIsPresented = false }
            } message: {
                Text("Your account is going to be deleted. Ok?")
            }
        }
    }

    var formPart1: some View {
        VStack {
            ZStack(alignment: verticalSizeClass == .compact ? .bottomLeading : .bottomTrailing) {
                Menu {
                    photoActionsMenu
                } label: {
                    profilePhoto
                }
                photoActionsMenuButton
                    .offset(x: verticalSizeClass == .compact ? -10 : 10)
            }
            Spacer()

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
                FormTextField(title: "Last name", value: $viewModel.lastName, inError: viewModel.lastNameInError)
            }

            VStack {
                FormTextField(title: "Email", value: $viewModel.email, inError: viewModel.emailInError)
                    .autocapitalization(.none)
            }

            Spacer()

            updateProfileButton

            Divider().overlay(Color.red).frame(height: 30)
//                .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))

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
        .navigationBarTitle("My profile")
        .padding()
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
