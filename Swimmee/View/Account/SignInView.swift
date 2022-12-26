//
//  SignInView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 23/09/2022.
//

import SwiftUI

struct SignInView: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    @StateObject var viewModel = SignSharedViewModel(formType: .signIn)

    // MARK: - Layout organization
    
    private var part1: some View {
        VStack {
            AppTitleView()
        }
    }

    private var part2: some View {
        VStack {
            Spacer()

            VStack(spacing: 30) {
                FormTextField("Email", value: $viewModel.email, inError: viewModel.emailInError)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .onChange(of: viewModel.email, perform: viewModel.formFieldChanged)

                FormTextField("Password", value: $viewModel.password, inError: viewModel.passwordInError, isSecure: true)
                    .textContentType(.password)
                    .onChange(of: viewModel.password, perform: viewModel.formFieldChanged)
            }

            Spacer()

            Button {
                viewModel.signIn()
            } label: {
                if viewModel.submitState == .inProgress {
                    ProgressView().frame(maxWidth: .infinity)
                } else {
                    Text("Log in").frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .opacity(viewModel.isReadyToSubmit ? 1 : 0.5)
            .keyboardShortcut(.defaultAction)

//            NavigationLink("I have lost my password...") {
//                Text("Not implemented")
//                    .foregroundColor(.secondary)
//            }

            Spacer()
        }
    }

    private var portraitView: some View {
        VStack {
            part1
            part2
        }
    }

    private var landscapeView: some View {
        HStack(spacing: 10) {
            part1
            part2
        }
    }

    var body: some View {
        Group {
            if verticalSizeClass == .compact {
                landscapeView
            } else {
                portraitView
            }
        }
        .padding()
        .onTapGesture {
            hideKeyboard()
        }
        .alert(viewModel.alertcontext) {}
        .navigationBarTitle("Sign In", displayMode: .inline)
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(viewModel: SignSharedViewModel(formType: .signIn))
    }
}
