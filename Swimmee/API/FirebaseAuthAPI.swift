//
//  FirebaseAuthAPI.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 16/10/2022.
//

import Combine
import FirebaseAuth
import FirebaseAuthCombineSwift
import Foundation

typealias UserId = String

enum AuthError: LocalizedError {
    case notAuthenticated
}

protocol AuthAPI {
    var isSgnedIn: Bool { get }
    var currentUserId: UserId? { get }
    
    func signedInStatePublisher() -> AnyPublisher<UserId?, Never>
        
    @discardableResult func signUp(email: String, password: String) async throws -> UserId
    @discardableResult func signIn(email: String, password: String) async throws -> UserId
    func reauthenticate(email: String, password: String) async throws
    func signOut() -> Bool
    
    func deleteCurrentUser() async throws
}

final class FirebaseAuthAPI: AuthAPI {
    var auth = Auth.auth()
    
    var isSgnedIn: Bool { auth.currentUser != nil }
    
    var currentUserId: UserId? {
        auth.currentUser?.uid
    }
    
    func getCurrentUserId() throws -> UserId {
        guard let userId = auth.currentUser?.uid else {
            throw AuthError.notAuthenticated
        }
        return userId
    }
    
    func signedInStatePublisher() -> AnyPublisher<UserId?, Never> {
        auth.authStateDidChangePublisher()
            .map { user in
                user?.uid
            }
            .eraseToAnyPublisher()
    }
    
    @discardableResult
    func signIn(email: String, password: String) async throws -> UserId  {
        let authDataResult = try await auth.signIn(withEmail: email, password: password)
        return authDataResult.user.uid
    }
    
    @discardableResult
    func signUp(email: String, password: String) async throws -> UserId {
        let authDataResult = try await auth.createUser(withEmail: email, password: password)
        return authDataResult.user.uid
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
    
    func reauthenticate(email: String, password: String) async throws {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        _ = try await auth.currentUser?.reauthenticate(with: credential)
    }
    
    func deleteCurrentUser() async throws {
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
}
