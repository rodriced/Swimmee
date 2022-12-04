//
//  SignInView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 23/09/2022.
//

import SwiftUI

struct SignInView: View {
    @StateObject var viewModel = SignSharedViewModel(formType: .signIn)

    var defaultBorderColor = RoundedBorderTextFieldStyle()

    var body: some View {
        VStack {
            AppTitleView()

            Spacer()

            VStack(spacing: 30) {
                TextField("Email", text: $viewModel.email)
                    .onChange(of: viewModel.email, perform: viewModel.formFieldChanged)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .roundedStyleWithErrorIndicator(inError: viewModel.emailInError)

                SecureField("Password", text: $viewModel.password)
                    .onChange(of: viewModel.password, perform: viewModel.formFieldChanged)
                    .roundedStyleWithErrorIndicator(inError: viewModel.passwordInError)

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
        SignInView(viewModel: SignSharedViewModel(formType: .signIn))
    }
}
