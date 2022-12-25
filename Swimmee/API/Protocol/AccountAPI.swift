//
//  AccountAPI.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 09/12/2022.
//

import Combine

enum AccountError: CustomError {
    case profileLoadingError
    case cantCreateProfile
    case emailAlreadyUsed
    case authenticationFailure
    case noUserSignedIn
    case userReplacedByAnother

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
        case .userReplacedByAnother:
            return "The current user has been replaced by another in the same session. It's not a normal behaviour... "
        }
    }
}

protocol AccountAPI {
    var isSgnedIn: Bool { get }
    
    var currentUserId: UserId? { get }
    func getCurrentUserId() throws -> UserId
    func currentUserIdPublisher() -> AnyPublisher<UserId?, Never>
    
    @discardableResult
    func signUp(email: String, password: String, userType: UserType, firstName: String, lastName: String) async throws -> Profile
    
    func deleteCurrrentAccount() async throws
    
    @discardableResult
    func signIn(email: String, password: String) async throws -> Profile
    
    func reauthenticate(email: String, password: String) async throws
    
    func signOut() -> Bool
    
    func updateEmail(to newEmail: String) async throws
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
