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

    @ObservedObject var vm: ProfileViewModel

    init(vm: ProfileViewModel) {
//        debugPrint("---- ProfileView created")
        _vm = ObservedObject(initialValue: vm)
    }

    var profilePhoto: some View {
        Group {
            switch vm.photoInfoEdited.state {
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
        Group {
            Button {
                vm.openPhotoPicker(.photoLibrary)
            } label: {
                Label("Photo from library", systemImage: "photo.on.rectangle")
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
            .disabled(!vm.photoInfoEdited.isImagePresent)
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
            vm.updateProfileConfirmationIsPresented = true
        } label: {
            Text("Update").frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .disabled(!vm.isReadyToSubmit)
        .confirmationDialog("Confirm your profile update.", isPresented: $vm.updateProfileConfirmationIsPresented) {
            Button("Confirm update") {
                vm.saveProfile()
                presentationMode.wrappedValue.dismiss()
            }
        }
        .keyboardShortcut(.defaultAction)
    }

    var deleteAccountButton: some View {
        Button {
            vm.reauthenticationViewIsPresented = true
        } label: {
            Text("Delete my account")
        }
        .foregroundColor(Color.red)
        .sheet(isPresented: $vm.reauthenticationViewIsPresented) {
            ReauthenticationView(
                viewModel: SignSharedViewModel(formType: .signIn),
                message: "You must reauthenticate to confirm\nthe deletion of your account.",
                reauthenticationSuccess: $vm.deleteAccountConfirmationIsPresented
            )
            .confirmationDialog("Confirme your account deletion", isPresented: $vm.deleteAccountConfirmationIsPresented) {
                Button("Confirm deletion", role: .destructive, action: vm.deleteAccount)
                Button("Cancel", role: .cancel) { vm.reauthenticationViewIsPresented = false }
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
                Text("\(vm.initialProfile.userType.rawValue)").font(.headline)
            }
        }
    }

    var formPart2: some View {
        VStack(spacing: 5) {
            VStack {
                FormTextField(title: "First name", value: $vm.firstName, inError: vm.firstNameInError)
                FormTextField(title: "Last name", value: $vm.lastName, inError: vm.lastNameInError)
            }

            VStack {
                FormTextField(title: "Email", value: $vm.email, inError: vm.emailInError)
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
        .sheet(isPresented: $vm.isPhotoPickerPresented) {
            ImagePicker(sourceType: vm.photoPickerImageSource, selectedImage: $vm.pickedPhoto)
        }
        .task { vm.startPublishers() }

        .navigationBarBackButtonHidden(vm.isReadyToSubmit)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                if vm.isReadyToSubmit {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
    }
}

// struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            ProfileView(vm: ProfileViewModel(profile: Profile.coachSample))
//        }
//    }
// }
