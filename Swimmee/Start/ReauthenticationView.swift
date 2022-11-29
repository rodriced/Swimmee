//
//  ReauthenticationView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 23/09/2022.
//

import SwiftUI

struct ReauthenticationView: View {
    @StateObject var viewModel: SignSharedViewModel
    @Environment(\.presentationMode) var presentationMode
    
    let message: String

    var defaultBorderColor = RoundedBorderTextFieldStyle()

    var body: some View {
        NavigationView {
            VStack {
                //            AppTitleView()
                Spacer()

                Text(message)
                    .multilineTextAlignment(.center)
                    .font(.system(.headline))
                Spacer()

                VStack(spacing: 30) {
                    TextField("Email", text: $viewModel.email)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .roundedStyleWithErrorIndicator(inError: viewModel.emailInError)

                    SecureField("Password", text: $viewModel.password)
                        .roundedStyleWithErrorIndicator(inError: viewModel.passwordInError)
                }

                Spacer()

                Button {
                    viewModel.reauthenticate()
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

struct ReauthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        ReauthenticationView(
            viewModel: SignSharedViewModel(formType: .signIn),
            message: "Explication message.\nMultiline...\nCentered"
        )
    }
}
