//
//  ProfileView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 23/09/2022.
//

import SDWebImageSwiftUI
import SwiftUI

class ProfileViewModel: ObservableObject {
//    var firstName = ""
//    var lastName = ""
//    let userType = UserType.swimmer
//    var email = ""

    @Published var profile: Profile

    @Published var isShowPhotoLibrary = false
    @Published var imageSourceType = UIImagePickerController.SourceType.photoLibrary
    @Published var image: UIImage? = nil
//    @Published var photoUrl: URL?

    @Published var authenticationSheet = false
    @Published var confirmationActionSheet = false

    required init(initialData: Profile) {
        debugPrint("---- ProfileViewModel.init")

        self.profile = initialData
    }

    deinit {
        debugPrint("---- ProfileViewModel deinit")
    }

    var restartLoader: (() -> Void)?
    
    func resetPhoto() {
        image = nil
        profile.photoUrl = nil
    }

    func saveProfile() {
        Task {
            if let image = image {
                do {
                    profile.photoUrl = try await API.shared.imageStorage.upload(uid: profile.userId, photo: image)
                } catch {
                    print("API.shared.imageStorage.upload error \(error.localizedDescription)")
                }
            }

            try? await API.shared.profile.save(profile)
//            self.photoUrl = profile.photoUrl
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

//    @State var photoActionsMenuShown = false

    init(vm: ProfileViewModel) {
        debugPrint("---- ProfileView created")
        _vm = ObservedObject(initialValue: vm)
    }
    
    var circlePhoto: some View {
        Group {
            if let image = vm.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if let photoUrl = vm.profile.photoUrl {
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
                    vm.isShowPhotoLibrary = true
                    vm.imageSourceType = .photoLibrary
                } label: {
                    Label("Choose from library", systemImage: "photo.on.rectangle")
                }
                Button {
                    vm.isShowPhotoLibrary = true
                    vm.imageSourceType = .camera
                } label: {
                    Label("Use camera", systemImage: "camera")
                }
                Button {
                    vm.resetPhoto()
                } label: {
                    Label("Remove photo", systemImage: "trash")
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
        .navigationTitle("My profile")
        .padding()
        .sheet(isPresented: $vm.isShowPhotoLibrary) {
            ImagePicker(sourceType: vm.imageSourceType, selectedImage: $vm.image)
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
