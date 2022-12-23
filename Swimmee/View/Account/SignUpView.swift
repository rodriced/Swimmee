//
//  SignUpView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 07/10/2022.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    @StateObject private var viewModel = SignSharedViewModel(formType: .signUp)

    @State private var userTypePickerOpened = false
    @State private var coachTypePicked = false
    @State private var swimmerTypePicked = false

    private var userTypePicker: some View {
        let buttonTitle =
            viewModel.userType.map { "I am a \($0.rawValue.capitalized)" } ?? "Are you a coach or a swimmer ?"

        return
            Menu {
                Button {
                    viewModel.userType = .swimmer
                } label: { Text("Swimmer") }
                Button {
                    viewModel.userType = .coach
                } label: { Text("Coach") }
            } label: {
                Text(buttonTitle)
                    .foregroundColor(.accentColor)
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(viewModel.userTypeInError ? Color.red : Color.clear, lineWidth: 0.5)
                    )
            }
            .onChange(of: viewModel.userType, perform: viewModel.formFieldChanged)
    }

    // MARK: - Layout organization

    private var part1: some View {
        VStack {
            Spacer()
            AppTitleView()
            Spacer(minLength: 20)
            Text("I create my account:").padding()
            Spacer()
        }
    }

    private var part2: some View {
        VStack {
            Spacer()

            VStack(spacing: 30) {
                VStack {
                    FormTextField("First name", value: $viewModel.firstName, inError: viewModel.firstNameInError)
                        .textContentType(.givenName)
                        .onChange(of: viewModel.firstName, perform: viewModel.formFieldChanged)

                    FormTextField("Last name", value: $viewModel.lastName, inError: viewModel.lastNameInError)
                        .textContentType(.familyName)
                        .onChange(of: viewModel.lastName, perform: viewModel.formFieldChanged)
                }

                userTypePicker

                VStack {
                    FormTextField("Email", value: $viewModel.email, inError: viewModel.emailInError)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .onChange(of: viewModel.email, perform: viewModel.formFieldChanged)

                    FormTextField("Password", value: $viewModel.password, inError: viewModel.passwordInError, isSecure: true)
                        .textContentType(.newPassword)
                        .onChange(of: viewModel.password, perform: viewModel.formFieldChanged)
                }
            }

            Spacer()

            Button {
                viewModel.signUp()
            } label: {
                if viewModel.submitState == .inProgress {
                    ProgressView().frame(maxWidth: .infinity)
                } else {
                    Text("Create account").frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .opacity(viewModel.isReadyToSubmit ? 1 : 0.5)
            .keyboardShortcut(.defaultAction)

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
        VStack {
            if verticalSizeClass == .compact {
                landscapeView
            } else {
                portraitView
            }
            HStack {
                Text("I already have an account...")
                NavigationLink("Let me in!", destination: SignInView.init)
            }
        }
        .padding()
        .onTapGesture {
            hideKeyboard()
        }
        .alert(viewModel.alertcontext) {}
        .navigationBarTitle("Join swimmee", displayMode: .inline)
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
