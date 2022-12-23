//
//  SignUpView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 07/10/2022.
//

import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = SignSharedViewModel(formType: .signUp)

    @Environment(\.verticalSizeClass) var verticalSizeClass

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

    var part1: some View {
        VStack {
            Spacer()
            AppTitleView()
            Spacer(minLength: 20)
            Text("I create my account:").padding()
            Spacer()
        }
    }

    var part2: some View {
        VStack {
            Spacer()

            VStack(spacing: 30) {
                VStack {
                    TextField("First name", text: $viewModel.firstName)
                        .roundedStyleWithErrorIndicator(inError: viewModel.firstNameInError)
                        .disableAutocorrection(true)
                        .onChange(of: viewModel.firstName, perform: viewModel.formFieldChanged)

                    TextField("Last name", text: $viewModel.lastName)
                        .roundedStyleWithErrorIndicator(inError: viewModel.lastNameInError)
                        .disableAutocorrection(true)
                        .onChange(of: viewModel.lastName, perform: viewModel.formFieldChanged)
                }

                userTypePicker

                VStack {
                    TextField("Email", text: $viewModel.email)
                        .roundedStyleWithErrorIndicator(inError: viewModel.emailInError)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .onChange(of: viewModel.email, perform: viewModel.formFieldChanged)

                    SecureField("Password", text: $viewModel.password)
                        .roundedStyleWithErrorIndicator(inError: viewModel.passwordInError)
                        .onChange(of: viewModel.password, perform: viewModel.formFieldChanged)
                }
            }

            Spacer()

            Button {
                viewModel.signUp()
            } label: {
                if viewModel.submiting {
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
