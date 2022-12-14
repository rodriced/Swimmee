//
//  ReauthenticationView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 23/09/2022.
//

import SwiftUI

struct ReauthenticationView: View {
    @Environment(\.presentationMode) var presentationMode
    var defaultBorderColor = RoundedBorderTextFieldStyle()

    @StateObject var viewModel: SignSharedViewModel
    let message: String
    @Binding var reauthenticationSuccess: Bool

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
//                .onChange(of: viewModel.submitSuccess) { $reauthenticationSuccess.wrappedValue = viewModel.submitSuccess }
            }
            .alert(viewModel.alertcontext) {}
            .padding()
            .navigationBarTitle("Reauthenticate", displayMode: .inline)
            .navigationBarItems(leading:
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: { Text("Cancel").bold() }
            )
            .onReceive(viewModel.$submitSuccess) { reauthenticationSuccess = $0 }
        }
    }
}

struct ReauthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        ReauthenticationView(
            viewModel: SignSharedViewModel(formType: .signIn),
            message: "Explication message.\nMultiline...\nCentered",
            reauthenticationSuccess: Binding.constant(false)
        )
    }
}
