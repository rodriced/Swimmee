//
//  SignInView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 23/09/2022.
//

import SwiftUI

struct SignInView: View {
    @StateObject var viewModel = CommonAccountViewModel(formType: .signIn)

    var defaultBorderColor = RoundedBorderTextFieldStyle()

    var body: some View {
        VStack {
            AppTitleView()

            Spacer()
            
//            AuthenticationView(viewModel: viewModel, reauthenticating: false)
//                .navigationBarTitle("Sign In", displayMode: .inline)


            VStack(spacing: 30) {
                TextField("Email", text: $viewModel.email)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .modifier(WithErrorIndicator(inError: $viewModel.emailInError))

                SecureField("Password", text: $viewModel.password)
                    .modifier(WithErrorIndicator(inError: $viewModel.passwordInError))
            }

            Spacer()

            Button {
                    viewModel.signIn()
            } label: {
                if viewModel.submiting {
                    ProgressView().frame(maxWidth: .infinity)
                } else {
                    Text("Log in").frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .opacity(viewModel.isReadyToSubmit ? 1 : 0.5)
            .keyboardShortcut(.defaultAction)

            NavigationLink("I have lost my password...", destination: Text("Lost password"))
        }
        .alert(viewModel.errorAlertMessage, isPresented: $viewModel.errorAlertIsPresenting) {}
        .padding()
//        .navigationBarTitle("Sign In", displayMode: .inline)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Sign in")
            }
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(viewModel: CommonAccountViewModel(formType: .signIn))
    }
}
