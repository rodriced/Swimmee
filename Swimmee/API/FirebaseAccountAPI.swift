//
//  FirebaseAccountAPI.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 21/10/2022.
//

import Combine
import FirebaseAuth
import FirebaseAuthCombineSwift

class FirebaseAccountAPI: AccountAPI {
    var auth = Auth.auth()

    var currentUserId: UserId? {
        auth.currentUser?.uid
    }

    private func currentUserIdPublisher() -> AnyPublisher<UserId?, Never> {
        auth.authStateDidChangePublisher()
            .map { user in
                user?.uid
            }
            .eraseToAnyPublisher()
    }

    func AuthenticationStatePublisher() -> AnyPublisher<AuthenticationState, Never> {
        currentUserIdPublisher()
            .flatMap { userId in
                switch userId {
                case .none:
                    return Just(AuthenticationState.signedOut)
                        .eraseToAnyPublisher()
                case .some(let userId):
                    return API.shared.profile.future(userId: userId)
                        .map(AuthenticationState.signedIn)
                        .catch { _ in
                            Just(AuthenticationState.failure(AccountError.profileLoadingError))
                        }
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    @discardableResult
    func signUp(email: String, password: String, userType: UserType, firstName: String, lastName: String) async throws -> Profile {
        let authDataResult = try await auth.createUser(withEmail: email, password: password)

        let profile = Profile(userId: authDataResult.user.uid,
                              userType: userType,
                              firstName: firstName,
                              lastName: lastName,
                              email: email)

        do {
            try await API.shared.profile.save(profile)
            return profile
        } catch {
            // Aborting acount creation
            try? await deleteCurrentUser()
            throw AccountError.cantCreateProfile
        }
    }

    private func deleteCurrentUser() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            guard let user = auth.currentUser else {
                continuation.resume()
                return
            }

            user.delete { error in
                if let error = error {
                    print("Delete current user error : \(String(describing: error))")
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    func deleteCurrrentAccount() async throws {
        guard let userId = currentUserId else {
            return
        }
        try await API.shared.profile.delete(userId: userId)
        try? await API.shared.imageStorage.delete(userId)

        try await deleteCurrentUser()
    }

    @discardableResult
    func signIn(email: String, password: String) async throws -> Profile {
        let authDataResult = try await auth.signIn(withEmail: email, password: password)

        do {
            return try await API.shared.profile.load(userId: authDataResult.user.uid)
        } catch {
            throw AccountError.profileLoadingError
        }
    }

    func reauthenticate(email: String, password: String) async throws {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        _ = try await auth.currentUser?.reauthenticate(with: credential)
    }

    func signOut() -> Bool {
        do {
            try auth.signOut()
            return true
        } catch {
            print("SignOut error : \(String(describing: error))")
            return false
        }
    }
}
