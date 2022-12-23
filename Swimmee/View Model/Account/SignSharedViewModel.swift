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

    static let formValidationErrorMessage = "Fields in red contain errors or are empty. Correct them and retry."

    enum FormType { case signUp, signIn }

    private var formType: FormType
    private let accountAPI: AccountAPI

    init(formType: FormType, accountAPI: AccountAPI = API.shared.account) {
        self.formType = formType
        self.accountAPI = accountAPI
    }

    @Published var firstName = ""
    @Published var lastName = ""
    @Published var userType: UserType? = nil
    @Published var email = ""
    @Published var password = ""

    @Published private(set) var firstNameInError = false
    @Published private(set) var lastNameInError = false
    @Published private(set) var userTypeInError = false
    @Published private(set) var emailInError = false
    @Published private(set) var passwordInError = false

    enum SubmitState { case pending, inProgress, success, falilure }
    @Published private(set) var submitState = SubmitState.pending

    private var formWasValidatedWithError = false

    @Published var alertcontext = AlertContext()

    private func submitForm(action: @escaping () async throws -> Void) {
        guard validateForm() else {
            formWasValidatedWithError = true
            alertcontext.message = Self.formValidationErrorMessage
            return
        }

        submitState = .inProgress

        Task {
            do {
                try await action()

                await MainActor.run {
                    submitState = .success
                }
            } catch {
                await MainActor.run {
                    submitState = .falilure
                    alertcontext.message = error.localizedDescription
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
    private func validateForm() -> Bool {
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
