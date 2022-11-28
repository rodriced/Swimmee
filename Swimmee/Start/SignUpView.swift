//
//  SignUpView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 07/10/2022.
//

import SwiftUI

struct SignUpView: View {
    @StateObject var viewModel = SignSharedViewModel(formType: .signUp)

    var body: some View {
        VStack {
            AppTitleView()

            Spacer(minLength: 20)

            Text("I create my account:").padding()

            VStack(spacing: 30) {
                VStack {
                    TextField("First name", text: $viewModel.firstName)
                        .disableAutocorrection(true)
                        .roundedStyleWithErrorIndicator(inError: viewModel.firstNameInError)

                    TextField("Last name", text: $viewModel.lastName)
                        .disableAutocorrection(true)
                        .roundedStyleWithErrorIndicator(inError: viewModel.lastNameInError)
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
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .roundedStyleWithErrorIndicator(inError: viewModel.emailInError)

                    SecureField("Password", text: $viewModel.password)
                        .roundedStyleWithErrorIndicator(inError: viewModel.passwordInError)
                }
            }
            .textFieldStyle(.roundedBorder)

            Spacer()

            Button {
                viewModel.signUp()
            } label: {
                if viewModel.submiting {
                    ProgressView().frame(maxWidth: .infinity)
                } else {
                    Text("Create account").frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .opacity(viewModel.isReadyToSubmit ? 1 : 0.5)
            .keyboardShortcut(.defaultAction)

            Text("I already have an account...")
            NavigationLink("Let me in!", destination: SignInView())
        }
        .padding()
//        .navigationBarTitle("Join swimmee", displayMode: .inline)
        //        .navigationTitle("Join Swimmee")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Join swimmee")
            }
        }
        .alert(viewModel.errorAlertMessage, isPresented: $viewModel.errorAlertIsPresenting) {}
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
