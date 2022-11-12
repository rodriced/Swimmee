//
//  SignUpView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 07/10/2022.
//

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

class CommonAccountViewModel: ObservableObject {
    enum FormType { case signUp, signIn }

    private var formType: FormType
    private var submitSuccess: Binding<Bool>?
    private let accountManager: AccountManager


    init(formType: FormType, submitSuccess: Binding<Bool>? = nil, authService: AccountManager = FirebaseAccountManager()) {
        self.formType = formType
        self.submitSuccess = submitSuccess
        self.accountManager = authService
    }

    @Published var firstName = ""
    @Published var lastName = ""
    @Published var userType = UserType.coach
    @Published var email = ""
    @Published var password = ""
    @Published var photoUrl: URL?

    @Published var firstNameInError = false
    @Published var lastNameInError = false
    @Published var emailInError = false
    @Published var passwordInError = false

//    enum FormState { case editing, submiting, submited(success: Bool)}

//    @Published var formState = FormState.editing
    @Published var submiting = false


    @Published var errorAlertIsPresenting = false {
        didSet {
            if errorAlertIsPresenting == false {
                errorAlertMessage = ""
            }
        }
    }

    var errorAlertMessage: String = "" {
        didSet {
            if !errorAlertMessage.isEmpty {
                errorAlertIsPresenting = true
            }
        }
    }

    private func submitForm(action: @escaping () async throws -> Void) {
        guard validateForm() else {
            return
        }

        submiting = true
//        formState = .submiting
        Task {
            do {
                try await action()

                await MainActor.run {
                    submiting = false
//                    formState = .submited(success: true)
                    if let submitSuccess = self.submitSuccess {
                        submitSuccess.wrappedValue = true
                    }
                }
            } catch {
                await MainActor.run {
                    submiting = false
//                    formState = .submited(success: false)
                    errorAlertMessage = error.localizedDescription
                }
            }
        }
    }

    func signUp() {
        submitForm { [self] in
            try await accountManager.signUp(email: email, password: password, userType: userType, firstName: firstName, lastName: lastName)
        }
    }

    func signIn() {
        submitForm { [self] in
            try await accountManager.signIn(email: email, password: password)
        }
    }

    func reauthenticate() {
        submitForm { [self] in
            try await accountManager.reauthenticate(email: email, password: password)
        }
    }

    private var isFirstNameValidated: Bool {
        return firstName != ""
    }

    private var isLastNameValidated: Bool {
        return lastName != ""
    }

    private var isEmailValidated: Bool {
        return email != ""
    }

    private var isPasswordValidated: Bool {
        return password != ""
    }

    var isReadyToSubmit: Bool {
        switch formType {
        case .signUp:
            return isFirstNameValidated && isLastNameValidated && isEmailValidated && isPasswordValidated
        case .signIn:
            return isEmailValidated && isPasswordValidated
        }
    }

    func validateForm() -> Bool {
        switch formType {
        case .signUp:
            firstNameInError = !isFirstNameValidated
            lastNameInError = !isLastNameValidated
            emailInError = !isEmailValidated
            passwordInError = !isPasswordValidated
        case .signIn:
            emailInError = !isEmailValidated
            passwordInError = !isPasswordValidated
        }

        return isReadyToSubmit
    }
}

struct SignUpView: View {
    @StateObject var viewModel = CommonAccountViewModel(formType: .signUp)

    var body: some View {
        VStack {
            AppTitleView()

            Spacer(minLength: 20)

            Text("I create my account:").padding()

            VStack(spacing: 30) {
                VStack {
                    TextField("First name", text: $viewModel.firstName)
                        .disableAutocorrection(true)
                        .modifier(WithErrorIndicator(inError: $viewModel.firstNameInError))

                    TextField("Last name", text: $viewModel.lastName)
                        .disableAutocorrection(true)
                        .modifier(WithErrorIndicator(inError: $viewModel.lastNameInError))
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
                        .modifier(WithErrorIndicator(inError: $viewModel.emailInError))

                    SecureField("Password", text: $viewModel.password)
                        .modifier(WithErrorIndicator(inError: $viewModel.passwordInError))
                }
            }
            .textFieldStyle(.roundedBorder)

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
        }
        .padding()
//        .navigationBarTitle("Join swimmee", displayMode: .inline)
        //        .navigationTitle("Join Swimmee")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Join swimmee")
            }
        }
        .alert(viewModel.errorAlertMessage, isPresented: $viewModel.errorAlertIsPresenting) {}
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
