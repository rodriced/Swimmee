//
//  ProfileView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 23/09/2022.
//

import SDWebImageSwiftUI
import SwiftUI

class ProfileViewModel: ObservableObject {
//    var originProfile: Profile
    @Published var profile: Profile
    
    @Published var isPhotoPickerPresented = false
    var photoPickeImageSource = UIImagePickerController.SourceType.photoLibrary
    @Published var pickedPhoto: UIImage? = nil

    @Published var authenticationSheet = false
    @Published var confirmationActionSheet = false

    required init(initialData: Profile) {
        debugPrint("---- ProfileViewModel.init")

        self.profile = initialData
//        self.originProfile = initialData
    }

    deinit {
        debugPrint("---- ProfileViewModel deinit")
    }
    
    var restartLoader: (() -> Void)?

    func openPhotoPicker(_ source: UIImagePickerController.SourceType) {
        isPhotoPickerPresented = true
        photoPickeImageSource = source
    }
    
    func clearPhoto() {
        pickedPhoto = nil
        profile.photo = nil
    }

    func updateSavedPhoto() async {
        guard let pickedPhoto = pickedPhoto else {
            do {
                try await API.shared.imageStorage.deleteImage(uid: profile.userId)
                profile.photo = nil
            } catch {
                print("ProfileViewModel.savePhoto (delete) error \(error.localizedDescription)")
            }
            return
        }

        do {
            let photoData = try ImageHelper.resizedImageData(from: pickedPhoto)
            let photoUrl = try await API.shared.imageStorage.upload(uid: profile.userId, imageData: photoData)
            profile.photo = PhotoInfo(url: photoUrl, data: photoData)
        } catch {
            print("ProfileViewModel.savePhoto (save) error \(error.localizedDescription)")
        }
    }

    func saveProfile() {
        Task {
            await updateSavedPhoto()
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

extension ProfileViewModel: LoadableViewModelV2 {
    typealias LoadedData = Profile

    func refreshedLoadedData(_ loadedData: Profile) {
        profile = loadedData
    }
}

struct ProfileView: View {
    @Environment(\.presentationMode) private var presentationMode

    @ObservedObject var vm: ProfileViewModel

    init(vm: ProfileViewModel) {
        debugPrint("---- ProfileView created")
        _vm = ObservedObject(initialValue: vm)
    }

    var circlePhoto: some View {
        Group {
            if let pickedPhoto = vm.pickedPhoto {
                Image(uiImage: pickedPhoto)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if let photoUrl = vm.profile.photo?.url {
                WebImage(url: photoUrl)
                    .resizable()
                    .placeholder(Image("UserPhotoPlaceholder"))
                    .scaledToFill()
//                            .aspectRatio(contentMode: .fill)
            } else {
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
                    vm.clearPhoto()
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
            AuthenticationView(viewModel: CommonAccountViewModel(formType: .signIn, submitSuccess: $vm.confirmationActionSheet)
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
                circlePhoto
                photoActionsMenu
                    .offset(x: 10)
            }

            Spacer()

            HStack {
                Text("I'm a")
                Text("\(vm.profile.userType.rawValue)").font(.headline)
            }
            Spacer()

            VStack(spacing: 30) {
                VStack {
                    TextField("First name", text: $vm.profile.firstName)
                    TextField("Last name", text: $vm.profile.lastName)
                }

                VStack {
                    TextField("Email", text: $vm.profile.email)
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
    }
}

// struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            ProfileView(vm: ProfileViewModel(profile: Profile.coachSample))
//        }
//    }
// }
