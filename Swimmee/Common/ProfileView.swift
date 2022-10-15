//
//  ProfileView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 23/09/2022.
//

import SwiftUI

class ProfileViewModel: ObservableObject {
//    var firstName = ""
//    var lastName = ""
//    let userType = UserType.swimmer
//    var email = ""

    @Published var profile = Profile.swimmerSample
    @Published var password = ""
}

struct ProfileView: View {
    @StateObject var vm = ProfileViewModel()
//    let photo = UIImage(data: Data())

    var body: some View {
//        NavigationView {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                Image("ProfilePhoto")
                    .resizable()
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(.blue, lineWidth: 4))
                    .shadow(radius: 6)
                Button(action: {}) { Image(systemName: "plus").font(.headline) }
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
        }.navigationTitle("My profile")
            .padding()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView()
        }
    }
}
