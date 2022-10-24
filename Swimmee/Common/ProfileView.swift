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

//    @Published var profile = Profile.swimmerSample
    @Published var userId = Service.shared.auth.currentUserId!
    @Published var profile = Profile.coachSample
//    @Published var profile

    @Published var password = ""

    @Published var isShowPhotoLibrary = false
    @Published var imageSourceType = UIImagePickerController.SourceType.photoLibrary
    @Published var image: UIImage? = nil
}

struct ProfileView: View {
    @StateObject var vm = ProfileViewModel()
//    let photo = UIImage(data: Data())

    var body: some View {
//        NavigationView {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if let image = vm.image {
                        Image(uiImage: image)
                            .resizable()
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
                    SecureField("Password", text: $vm.password)
                }
            }
            .textFieldStyle(.roundedBorder)

            Spacer()

            Button(action: {}) {
                Text("Update").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
//            .keyboardShortcut(.defaultAction)
//        }
            Divider().overlay(Color.red).frame(height: 30)
//                .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
            NavigationLink("Delete my account", destination: Text("Account deleted")).foregroundColor(Color.red)
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
            ProfileView()
        }
    }
}
