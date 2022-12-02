//
//  Account.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 21/10/2022.
//

import Combine
import FirebaseAuth
import FirebaseAuthCombineSwift

enum AccountError: CustomError {
    case profileLoadingError
    case cantCreateProfile
    case emailAlreadyUsed
    case authenticationFailure
    case noUserSignedIn

    var description: String {
        switch self {
        case .profileLoadingError:
            return "User profile could not be loaded."
        case .cantCreateProfile:
            return "User profile could not be created."
        case .emailAlreadyUsed:
            return "Email is already used"
        case .authenticationFailure:
            return "Authentication failure"
        case .noUserSignedIn:
            return "No user authenticated"
        }
    }
}

enum AccountSignedState {
    case undefined, signedIn(Profile), signedOut, failure(Error)
}

protocol AccountAPI {
    var isSgnedIn: Bool { get }
    
    var currentUserId: UserId? { get }
    func getCurrentUserId() throws -> UserId

    func signedStatePublisher() -> AnyPublisher<AccountSignedState, Never>

    @discardableResult
    func signUp(email: String, password: String, userType: UserType, firstName: String, lastName: String) async throws -> Profile
    
    func deleteCurrrentAccount() async throws
    
    @discardableResult
    func signIn(email: String, password: String) async throws -> Profile
    
    func reauthenticate(email: String, password: String) async throws
    
    func signOut() -> Bool
}

extension AccountAPI {
    var isSgnedIn: Bool { currentUserId != nil }
    
    func getCurrentUserId() throws -> UserId {
        guard let userId = currentUserId else {
            throw AccountError.noUserSignedIn
        }
        return userId
    }
}

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
    
    func signedStatePublisher() -> AnyPublisher<AccountSignedState, Never> {
        currentUserIdPublisher()
            .flatMap { userId in
                switch userId {
                case .none:
                    return Just(AccountSignedState.signedOut)
                        .eraseToAnyPublisher()
                case .some(let userId):
                    return API.shared.profile.future(userId: userId)
                        .map(AccountSignedState.signedIn)
                        .catch { _ in
                            Just(AccountSignedState.failure(AccountError.profileLoadingError))
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
        try? await API.shared.imageStorage.deleteImage(uid: userId)
        
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

// extension ConnectionStatus {
//    func getProfile(throwing customError: Error) throws -> Profile {
//        switch self {
//        case let .signedIn(profile):
//            return profile
//        case let .failure(error):
//            throw error
//        default:
//            throw customError
//        }
//    }
// }
//
// class FakeAccountManager: AccountManager {
//    enum Err: Error {
//        case signUpError
//        case signInError
//        case deleteCurrentAccountError
//        case reauthenticateError
//    }
//
//    let connectionStatus: ConnectionStatus
//
//    init(connectionStatus: ConnectionStatus) {
//        self.connectionStatus = connectionStatus
//    }
//
//    func signUp(email: String, password: String, userType: UserType, firstName: String, lastName: String) async throws -> Profile {
//        try connectionStatus.getProfile(throwing: Err.signUpError)
//    }
//
//    func deleteCurrrentAccount() async throws {
//        _ = try connectionStatus.getProfile(throwing: Err.deleteCurrentAccountError)
//    }
//
//    func signIn(email: String, password: String) async throws -> Profile {
//        try connectionStatus.getProfile(throwing: Err.signInError)
//    }
//
//    func reauthenticate(email: String, password: String) async throws {
//        _ = try connectionStatus.getProfile(throwing: Err.reauthenticateError)
//    }
// }
