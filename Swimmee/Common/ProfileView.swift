//
//  ProfileView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 23/09/2022.
//

import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType = .photoLibrary

    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator

        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
//            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//                parent.selectedImage = image
//            }
            parent.selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage

            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

class ProfileViewModel: ObservableObject {
//    var firstName = ""
//    var lastName = ""
//    let userType = UserType.swimmer
//    var email = ""

    @Published var profile: Profile

    @Published var isShowPhotoLibrary = false
    @Published var imageSourceType = UIImagePickerController.SourceType.photoLibrary
    @Published var image: UIImage? = nil

    @Published var authenticationSheet = false
    @Published var confirmationActionSheet = false

    init(profile: Profile) {
        self.profile = profile

        if profile.hasPhoto {
            Task {
                let photoData = try? await Service.shared.storage.downloaddPhoto(uid: profile.userId)
                guard let photoData = photoData else {
                    return
                }
                await MainActor.run {
                    image = UIImage(data: photoData)
                }
            }
        }
    }

    func saveProfile() {
        Task {
            if let image = image {
                try? await Service.shared.storage.uploadPhoto(uid: profile.userId, photo: image)
                await MainActor.run {
                    profile.hasPhoto = true
                }
            }

            try? await Service.shared.store.saveProfile(profile: profile)
        }
    }

//    func reauthenticate() {
//        Service.shared.auth.reauthenticate(email: , password: <#T##String#>)
//    }

    func deleteAccount() {
        Task {
            try await Account.deleteCurrrentAccount()
        }
    }
}

struct ProfileViewInit: View {
    @EnvironmentObject var userSession: UserSession
    @State var profile: Profile?

    func getProfile() async -> Profile? {
        guard let userId = Service.shared.auth.currentUserId else {
            return nil
        }
        return try? await Service.shared.store.loadProfile(userId: userId)
    }

    var body: some View {
        Group {
            if let profile = profile {
                ProfileView(vm: ProfileViewModel(profile: profile))
            } else {
                ProgressView()
            }
        }
        .task {
            profile = await getProfile()
        }
    }
}

struct ProfileView: View {
    @StateObject var vm: ProfileViewModel
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if let image = vm.image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
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

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView(vm: ProfileViewModel(profile: Profile.coachSample))
        }
    }
}
