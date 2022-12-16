//
//  SignUpView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 07/10/2022.
//

import SwiftUI

struct SignUpView: View {
    @StateObject var viewModel = SignSharedViewModel(formType: .signUp)

    @State var userTypePickerOpened = false
    @State var coachTypePicked = false
    @State var swimmerTypePicked = false

    var userTypePicker: some View {
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

    var body: some View {
        VStack {
            AppTitleView()

            Spacer(minLength: 20)

            Text("I create my account:").padding()

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

            Text("I already have an account...")
            NavigationLink("Let me in!", destination: SignInView())

            Spacer()
        }
        .padding()
        .alert(viewModel.alertcontext) {}
        .navigationBarTitle("Join swimmee", displayMode: .inline)
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
