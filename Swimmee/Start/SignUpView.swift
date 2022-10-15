//
//  SignUpView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 07/10/2022.
//

import SwiftUI


class SignUpViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var userType = UserType.coach
    @Published var email = ""
    @Published var password = ""
}

// struct WideButtonStyle: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label.frame(maxWidth: .infinity)
//    }
// }

struct SignUpView: View {
    @StateObject var viewModel = SignUpViewModel()

    var body: some View {
        NavigationView {
            VStack {
                AppTitleView()
                    .navigationBarTitle("Join swimmee", displayMode: .inline)

                Spacer(minLength: 20)

                Text("I create my account:").padding()

                VStack(spacing: 30) {
                    VStack {
                        TextField("First name", text: $viewModel.firstName)
                        TextField("Last name", text: $viewModel.lastName)
                    }

                    HStack {
                        Text("I'm a ")
                        Picker("UserType", selection: $viewModel.userType) {
                            ForEach(UserType.allCases) { userType in
                                Text(userType.rawValue.capitalized)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    VStack {
                        TextField("Email", text: $viewModel.email)
                        SecureField("Password", text: $viewModel.password)
                    }
                }
                .textFieldStyle(.roundedBorder)

                Spacer()

                Button(action: {}) {
                    Text("Sign up").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)

                Text("I already have an account...")
                NavigationLink("Let me in!", destination: SignInView())
            }
            .padding()
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
