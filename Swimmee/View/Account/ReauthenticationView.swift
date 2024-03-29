//
//  ReauthenticationView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 23/09/2022.
//

import SwiftUI

struct ReauthenticationView<Message: View>: View {
    @Environment(\.presentationMode) private var presentationMode
    private func dismiss() { presentationMode.wrappedValue.dismiss() }

    @StateObject private var viewModel = SignSharedViewModel(formType: .signIn)

    private let title: String
    private let message: () -> Message
    private let emailTitle: String
    private let passwordTitle: String
    private let buttonLabel: String
    private var successCompletion: (() -> Void)?
    private var cancelCompletion: (() -> Void)?

    init(title: String = "Reauthenticate",
         @ViewBuilder message: @escaping () -> Message = { Text("You nust reauthenticate to continue.") },
         emailTitle: String = "Email",
         passwordTitle: String = "Password",
         buttonLabel: String = "Ok",
         successCompletion: (() -> Void)? = nil,
         cancelCompletion: (() -> Void)? = nil)
    {
        self.title = title
        self.message = message
        self.emailTitle = emailTitle
        self.passwordTitle = passwordTitle
        self.buttonLabel = buttonLabel
        self.successCompletion = successCompletion
        self.cancelCompletion = cancelCompletion
    }

    private var formfields: some View {
        VStack(spacing: 30) {
            FormTextField(emailTitle, value: $viewModel.email, inError: viewModel.emailInError)
                .textContentType(.emailAddress)
                .autocapitalization(.none)

            FormTextField(passwordTitle, value: $viewModel.password, inError: viewModel.passwordInError, isSecure: true)
                .textContentType(.password)
        }
    }

    private var submitButton: some View {
        Button {
            viewModel.reauthenticate()
        } label: {
            if viewModel.submitState == .inProgress {
                ProgressView().frame(maxWidth: .infinity)
            } else {
                Text(buttonLabel).frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.borderedProminent)
        .opacity(viewModel.isReadyToSubmit ? 1 : 0.5)
    }

    var body: some View {
        NavigationView {
            VStack {
                Spacer()

                message()
                    .multilineTextAlignment(.center)
                    .font(.system(.headline))

                Spacer()
                formfields
                Spacer()

                submitButton
            }
            .padding()
            .onTapGesture {
                hideKeyboard()
            }
            .alert(viewModel.alertcontext) {}
            .navigationBarTitle(title, displayMode: .inline)
            .navigationBarItems(leading:
                Button {
                    dismiss()
                    cancelCompletion?()
                } label: { Text("Cancel").bold() }
            )
            .onReceive(viewModel.$submitState) {
                switch $0 {
                case .success:
                    dismiss()
                    successCompletion?()
                default:
                    ()
                }
            }
        }
    }
}

struct ReauthenticationView2_Previews: PreviewProvider {
    static var previews: some View {
        ReauthenticationView()
    }
}
