//
//  Account.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 21/10/2022.
//

//import Combine
//import Foundation

protocol AccountManager {
    @discardableResult
    func signUp(email: String, password: String, userType: UserType, firstName: String, lastName: String) async throws -> Profile
    
    func deleteCurrrentAccount() async throws
    
    @discardableResult
    func signIn(email: String, password: String) async throws -> Profile
    
    func reauthenticate(email: String, password: String) async throws
}

class FirebaseAccountManager: AccountManager {
    enum AccountErr: Error { case profileSaveError(Error) }
    
    @discardableResult
    func signUp(email: String, password: String, userType: UserType, firstName: String, lastName: String) async throws -> Profile {
        let userId = try await API.shared.auth.signUp(email: email, password: password)
        
        let profile = Profile(userId: userId, userType: userType, firstName: firstName, lastName: lastName, email: email)
        do {
            try await API.shared.profile.save(profile)
            return profile
        } catch {
            // Aborting acount creation
            try? await API.shared.auth.deleteCurrentUser()
            throw AccountErr.profileSaveError(error)
        }
    }
    
    func deleteCurrrentAccount() async throws {
        let userId = API.shared.auth.currentUserId
        guard let userId = userId else {
            return
        }
        try await API.shared.profile.delete(userId: userId)
        try await API.shared.imageStorage.deleteImage(uid: userId)
        
        try await API.shared.auth.deleteCurrentUser()
    }
    
    @discardableResult
    func signIn(email: String, password: String) async throws -> Profile {
        let userId = try await API.shared.auth.signIn(email: email, password: password)
        return try await API.shared.profile.load(userId: userId)
    }
    
    func reauthenticate(email: String, password: String) async throws {
        try await API.shared.auth.reauthenticate(email: email, password: password)
    }
    
//    func profileFuture(userId: UserId) -> Future<Profile?, Never> {
//        Future { promise in
//            Task {
//                do {
//                    let userProfile = try await API.shared.profile.load(userId: userId)
//                    promise(.success(userProfile))
//                } catch {
//                    promise(.success(nil))
//                }
//            }
//        }
//    }
    
//    func t() {
//        let p: AnyPublisher<Profile?, Never> = API.shared.profile.future(userId: "")
//            .map { profile in Profile?(profile) }
//            .replaceError(with: Profile?(nil))
//            .eraseToAnyPublisher()
//    }
}

extension ConnectionStatus {
    func getProfile(throwing customError: Error) throws -> Profile {
        switch self {
        case let .signedIn(profile):
            return profile
        case let .failure(error):
            throw error
        default:
            throw customError
        }
    }
}

class MockedAccountManager: AccountManager {
    enum Err: Error {
        case signUpError
        case signInError
        case deleteCurrentAccountError
        case reauthenticateError
    }

    let connectionStatus: ConnectionStatus
    
    init(connectionStatus: ConnectionStatus) {
        self.connectionStatus = connectionStatus
    }
    
    func signUp(email: String, password: String, userType: UserType, firstName: String, lastName: String) async throws -> Profile {
        try connectionStatus.getProfile(throwing: Err.signUpError)
    }
    
    func deleteCurrrentAccount() async throws {
        _ = try connectionStatus.getProfile(throwing: Err.deleteCurrentAccountError)
    }
    
    func signIn(email: String, password: String) async throws -> Profile {
        try connectionStatus.getProfile(throwing: Err.signInError)
    }
        
    func reauthenticate(email: String, password: String) async throws {
        _ = try connectionStatus.getProfile(throwing: Err.reauthenticateError)
    }
}
