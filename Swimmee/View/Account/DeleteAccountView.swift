//
//  DeleteAccountView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 23/12/2022.
//

import SwiftUI

struct DeleteAccountView: View {
    @State private var deleteAccountConfirmationIsPresented = false
    @State private var notImplementedAlertPresented = false

    var cancelCompletion: () -> Void

    var body: some View {
        ReauthenticationView(
            viewModel: SignSharedViewModel(formType: .signIn),
            message: "You must reauthenticate to confirm\nthe deletion of your account.",
            reauthenticationSuccess: $deleteAccountConfirmationIsPresented
        )
        .confirmationDialog("Confirme your account deletion", isPresented: $deleteAccountConfirmationIsPresented) {
//            Button("Confirm deletion", role: .destructive, action: viewModel.deleteAccount)
            Button("Confirm deletion", role: .destructive) { notImplementedAlertPresented = true }
            Button("Cancel", role: .cancel, action: cancelCompletion)
        } message: {
            Text("Your account is going to be deleted. Ok?")
        }
        .alert("Functionality not implemented", isPresented: $notImplementedAlertPresented) {
            Button("Ok") {
                deleteAccountConfirmationIsPresented = false
                cancelCompletion()
            }
        }
    }
}

struct DeleteAccountView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteAccountView(cancelCompletion: {})
    }
}
