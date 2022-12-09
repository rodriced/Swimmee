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

enum AuthenticationState: Equatable {
    case undefined, signedIn(Profile), signedOut, failure(Error)
    
    static func == (lhs: AuthenticationState, rhs: AuthenticationState) -> Bool {
        switch (lhs, rhs) {
        case (.signedIn(let lhsProfile), .signedIn(let rhsProfile)) where lhsProfile.userId == rhsProfile.userId:
            return true
            
        case (.undefined, .undefined),
             (.signedOut, .signedOut),
            (.failure(_), .failure(_)):
            return true
    
        default:
            return false
        }
    }
}

protocol AccountAPI {
    var isSgnedIn: Bool { get }
    
    var currentUserId: UserId? { get }
    func getCurrentUserId() throws -> UserId

    func AuthenticationStatePublisher() -> AnyPublisher<AuthenticationState, Never>

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
