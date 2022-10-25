//
//  AuthenticationView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 23/09/2022.
//

import SwiftUI

struct AuthenticationView: View {
//    @StateObject var viewModel = CommonAccountViewModel(formType: .signIn)
    @StateObject var viewModel: CommonAccountViewModel
    @Environment(\.presentationMode) var presentationMode
//    var reauthenticating = false

//    var submitAction: (() -> Void)?
//    var submitTitle: String?

    var defaultBorderColor = RoundedBorderTextFieldStyle()

    var body: some View {
        NavigationView {
            VStack {
                //            AppTitleView()

                Spacer()

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
                    viewModel.reauthenticate()
//                    submitAction?()
                } label: {
                    if viewModel.submiting {
                        ProgressView().frame(maxWidth: .infinity)
                    } else {
                        Text("Reauthenticate").frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .opacity(viewModel.isReadyToSubmit ? 1 : 0.5)
                .keyboardShortcut(.defaultAction)
            }
            .alert(viewModel.errorAlertMessage, isPresented: $viewModel.errorAlertIsPresenting) {}
            .padding()
            .navigationBarTitle("Reauthenticate", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Cancel").bold()
            })
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView(viewModel: CommonAccountViewModel(formType: .signIn))
    }
}
