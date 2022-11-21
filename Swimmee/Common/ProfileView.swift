//
//  ProfileView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 23/09/2022.
//

import SwiftUI
import SDWebImageSwiftUI

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

    init(profile: Profile) {
        debugPrint("---- ProfileViewModel.init")

        self.profile = profile
//        self.photoUrl = profile.photoUrl

//        if let photoUrl = profile.photoUrl {
//            Task {
//                let photoData = try? await API.shared.imageStorage.downloadd(uid: profile.userId)
//                guard let photoData = photoData else {
//                    return
//                }
//                await MainActor.run {
//                    image = UIImage(data: photoData)
//                }
//            }
//        }
    }
    
    deinit {
        debugPrint("---- ProfileViewModel deinit")
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
        // TODO Implement this with Firebase function
        // To test. Blocking main thread to prevent ececution of swiftui ui update until account deletion (photo, profile, auth user) completion to prevent inconsistent state
        _ = DispatchQueue.main.sync {
            Task {
                try await FirebaseAccountManager().deleteCurrrentAccount()
            }
        }
    }
}

struct ProfileViewInit: View {
    @EnvironmentObject var session: UserSession

    enum LodingState { case loading, loaded(Profile), failure(String) }
    @State var loadingState = LodingState.loading

    func getProfile() async throws -> Profile? {
//        return try await API.shared.store.loadProfile(userId: session.userId)
        return try await API.shared.profile.load(userId: session.userId)
    }

    var body: some View {
        Group {
            switch loadingState {
            case .loading:
                ProgressView()
            case .loaded(let profile):
                ProfileView(vm: ProfileViewModel(profile: profile))
            case .failure(let errorMsg):
                Text("\(errorMsg)\nVerify your connectivity\nand come back on this page.")
            }
        }
        .task {
            do {
                loadingState = .loading
                let profile = try await getProfile()
                guard let profile = profile else {
                    loadingState = .failure("No profile (impossible error)")
                    return
                }
                loadingState = .loaded(profile)
            } catch {
                loadingState = .failure(error.localizedDescription)
            }
        }
    }
}

struct ProfileView: View {
    @Environment(\.presentationMode) private var presentationMode

    @StateObject var vm: ProfileViewModel

    init(vm: @autoclosure @escaping () -> ProfileViewModel) {
        _vm = StateObject(wrappedValue: vm())
        debugPrint("---- ProfileView created")
    }
    
//        init(vm: ProfileViewModel) {
//            _vm = StateObject(wrappedValue: vm)
//            debugPrint("---- ProfileView created")
//        }

//    @ObservedObject var vm: ProfileViewModel
//
//    init(vm: ProfileViewModel) {
//        _vm = ObservedObject(wrappedValue: vm)
//        debugPrint("---- ProfileView created")
//    }

    var body: some View {
        VStack {
//            { () -> EmptyView in
//                debugPrint("---- ProfileView.body executed")
//                return EmptyView()
//            }()
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if let image = vm.image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else if let photoUrl = vm.profile.photoUrl {
                        WebImage(url: photoUrl)
                            .resizable()
                            .placeholder(Image(systemName: "ProfilePhoto"))
                            .scaledToFill()
//                            .aspectRatio(contentMode: .fill)
                    } else {
                        Image("ProfilePhoto")
                            .resizable()
                    }
                }
                .frame(width: 200, height: 200)
                .clipShape(Circle())
                .overlay(Circle().stroke(.blue, lineWidth: 4))
                .shadow(radius: 6)

                HStack {
                    Button {
                        vm.isShowPhotoLibrary = true
                        vm.imageSourceType = .photoLibrary
                    } label: { Image(systemName: "plus").font(.headline) }
                    Button {
                        vm.isShowPhotoLibrary = true
                        vm.imageSourceType = .camera
                    } label: { Image(systemName: "camera").font(.headline) }
                }
                .offset(x: 10)
            }

//            Form {
            ////                    TextField("First name", value: $viewModel.firstname, formatter: PersonNameComponentsFormatter())
//                TextField("First name", text: $vm.firstName)
//                TextField("Last name", text: $vm.lastName)
//            }.padding()

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
//        }
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

//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            ProfileView(vm: ProfileViewModel(profile: Profile.coachSample))
//        }
//    }
//}
