//
//  SignUpView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 07/10/2022.
//

import FirebaseAuth
import SwiftUI

class FieldValidation {
    static func validateEmail(email: String) -> Bool {
        return email != ""
    }

    static func validatePassword(password: String) -> Bool {
        return password != ""
    }
    
    static func validateFirstName(firstName: String) -> Bool {
        return firstName != ""
    }
    static func validateLastName(lastName: String) -> Bool {
        return lastName != ""
    }
}

class SignUpViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var userType = UserType.coach
    @Published var email = ""
    @Published var password = ""

    @Published var emailError = false
    @Published var passwordError = false

    @Published var signingUp = false

    @Published var signUpAlertIsPresenting = false

    func signUp() async -> Bool {
        await Service.shared.auth.signUp(email: email, password: password)
    }

    func signUp2() {
        guard validateForm() else {
            return
        }

        signingUp = true
        Task {
            let isSignUpSuccess = await Service.shared.auth.signUp(email: email, password: password)
            
            DispatchQueue.main.sync {
                signingUp = false
                signUpAlertIsPresenting = !isSignUpSuccess
            }
        }
    }

    @MainActor
    func resetForm() {
        email = ""
        password = ""

        emailError = false
        passwordError = false
    }

    var isEmailValidated: Bool {
        return email != ""
    }

    var isPasswordValidated: Bool {
        return password != ""
    }

    var isReadyToSubmit: Bool {
        isEmailValidated && isPasswordValidated
    }

    func validateForm() -> Bool {
        emailError = !isEmailValidated
        passwordError = !isPasswordValidated
        return isReadyToSubmit
    }
}

struct SignUpView: View {
    @StateObject var viewModel = SignUpViewModel()

    var body: some View {
        NavigationView {
            VStack {
                AppTitleView()
                    .navigationBarTitle("Join swimmee", displayMode: .inline)

                Spacer(minLength: 20)

                Text("I create my account:").padding()

                VStack(spacing: 30) {
                    VStack {
                        TextField("First name", text: $viewModel.firstName)

                        TextField("Last name", text: $viewModel.lastName)
                    }

                    HStack {
                        Text("I'm a ")
                        Picker("UserType", selection: $viewModel.userType) {
                            ForEach(UserType.allCases) { userType in
                                Text(userType.rawValue.capitalized)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    VStack {
                        TextField("Email", text: $viewModel.email)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .if(viewModel.emailError) {
                                $0.border(Color.red)
                            }
                        SecureField("Password", text: $viewModel.password)
                            .if(viewModel.passwordError) {
                                $0.border(Color.red)
                            }
                    }
                }
                .textFieldStyle(.roundedBorder)

                Spacer()

                Button {
//                    guard viewModel.validateForm() else {
//                        return
//                    }
//
//                    viewModel.signingUp = true
//                    Task {
//                        let isSignUpSuccess = await viewModel.signUp()
//                        viewModel.signingUp = false
//                        viewModel.signUpAlertIsPresenting = !isSignUpSuccess
//                    }
                    viewModel.signUp2()
                } label: {
                    if viewModel.signingUp {
                        ProgressView().frame(maxWidth: .infinity)
                    } else {
                        Text("Sign up").frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .opacity(viewModel.isReadyToSubmit ? 1 : 0.5)
                .keyboardShortcut(.defaultAction)

                Text("I already have an account...")
                NavigationLink("Let me in!", destination: SignInView())
            }
            .alert("Sign up Error", isPresented: $viewModel.signUpAlertIsPresenting) {}
            .padding()
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
