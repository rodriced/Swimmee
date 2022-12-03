//
//  SignSharedViewModel.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 28/11/2022.
//

import Combine

class SignSharedViewModel: ObservableObject {
    enum SignUpError: String, Error {
        case userTypeWithoutValue = "User type hasn't value. It can't happened so it's a bug ! Please, send a report."
    }

    enum FormType { case signUp, signIn }

    private var formType: FormType
    private let accountAPI: AccountAPI

    init(formType: FormType, accountAPI: AccountAPI = FirebaseAccountAPI()) {
        self.formType = formType
        self.accountAPI = accountAPI
    }

    @Published var firstName = ""
    @Published var lastName = ""
    @Published var userType: UserType? = nil
    @Published var email = ""
    @Published var password = ""

    @Published var firstNameInError = false
    @Published var lastNameInError = false
    @Published var userTypeInError = false
    @Published var emailInError = false
    @Published var passwordInError = false

    @Published var submiting = false
    @Published var submitSuccess = false

    var formWasValidatedWithError = false

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
            formWasValidatedWithError = true
            errorAlertMessage = "Fields in red contain errors. Correct them and retry."
            return
        }

        submiting = true

        Task {
            do {
                try await action()

                await MainActor.run {
                    submiting = false
                    submitSuccess = true
                }
            } catch {
                await MainActor.run {
                    submiting = false

                    errorAlertMessage = error.localizedDescription
                }
            }
        }
    }

    func signUp() {
        submitForm { [self] in
            guard let userType else { throw SignUpError.userTypeWithoutValue }
            // TODO: userType shouldn't be unwrapped here because it's an impossible case. Design to review.

            try await accountAPI.signUp(email: email, password: password, userType: userType, firstName: firstName, lastName: lastName)
        }
    }

    func signIn() {
        submitForm { [self] in
            try await accountAPI.signIn(email: email, password: password)
        }
    }

    func reauthenticate() {
        submitForm { [self] in
            try await accountAPI.reauthenticate(email: email, password: password)
        }
    }

    func formFieldChanged<T>(_: T) {
        guard formWasValidatedWithError else { return }
        validateForm()
    }

    private var isFirstNameValidated: Bool {
        ValueValidation.validateFirstName(firstName)
    }

    private var isLastNameValidated: Bool {
        ValueValidation.validateLastName(lastName)
    }

    private var isUserTypeValidated: Bool {
        userType != nil
    }

    private var isEmailValidated: Bool {
        ValueValidation.validateEmail(email)
    }

    private var isPasswordValidated: Bool {
        ValueValidation.validatePassword(password)
    }

    var isReadyToSubmit: Bool {
        switch formType {
        case .signUp:
            return isFirstNameValidated
                && isLastNameValidated
                && isUserTypeValidated
                && isEmailValidated
                && isPasswordValidated
        case .signIn:
            return isEmailValidated && isPasswordValidated
        }
    }

    @discardableResult
    func validateForm() -> Bool {
        switch formType {
        case .signUp:
            firstNameInError = !isFirstNameValidated
            lastNameInError = !isLastNameValidated
            userTypeInError = !isUserTypeValidated
            emailInError = !isEmailValidated
            passwordInError = !isPasswordValidated
        case .signIn:
            emailInError = !isEmailValidated
            passwordInError = !isPasswordValidated
        }

        return isReadyToSubmit
    }
}
