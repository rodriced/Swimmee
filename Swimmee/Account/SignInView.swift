//
//  SignInView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 23/09/2022.
//

import SwiftUI

struct SignInView: View {
    @StateObject var viewModel = SignSharedViewModel(formType: .signIn)
    
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var defaultBorderColor = RoundedBorderTextFieldStyle()

    var part1: some View {
        VStack {
            AppTitleView()
        }
    }

    var part2: some View {
        VStack {
            Spacer()

            VStack(spacing: 30) {
                TextField("Email", text: $viewModel.email)
                    .roundedStyleWithErrorIndicator(inError: viewModel.emailInError)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .onChange(of: viewModel.email, perform: viewModel.formFieldChanged)

                SecureField("Password", text: $viewModel.password)
                    .roundedStyleWithErrorIndicator(inError: viewModel.passwordInError)
                    .onChange(of: viewModel.password, perform: viewModel.formFieldChanged)
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

            NavigationLink("I have lost my password...") {
                Text("Not implemented")
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }

    var portraitView: some View {
        VStack {
            part1
            part2
        }
    }

    var landscapeView: some View {
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
        .alert(viewModel.alertcontext) {}
        .padding()
        .navigationBarTitle("Sign In", displayMode: .inline)
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(viewModel: SignSharedViewModel(formType: .signIn))
    }
}
