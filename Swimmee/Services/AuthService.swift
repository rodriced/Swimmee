//
//  AuthService.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 16/10/2022.
//

import Combine
import FirebaseAuth
import FirebaseAuthCombineSwift
import Foundation

protocol AuthService {
    var isSgnedIn: Bool { get }
    var currentProfile: Profile? { get }
    
    associatedtype StatePublisher: Publisher<Bool, Never>
    func signedInStateChangePublisher() -> StatePublisher
    
//    associatedtype StatePublisher: Publisher<Bool, Failure> where Failure == Never
//    func signedInStateChangePublisher() -> Publisher<Profile, Failure> where Failure: Never
    
    func signIn(email: String, password: String) async -> Bool
    func signOut() -> Bool
    
    func signUp(email: String, password: String) async -> Bool
    func deleteCurrentUser() async -> Bool
}

final class FirebaseAuthService {
    var auth = Auth.auth()
    
    var isSgnedIn: Bool { auth.currentUser != nil }
    var currentProfile: Profile? {
        guard let currentUser = auth.currentUser else {
            return nil
        }
        
        guard let email = currentUser.email else {
            print("CurrentUser error : email has no value")
            return nil
        }
        
        return Profile(userType: .coach, firstName: "", lastName: "", email: email)
    }
    
    func signedInStateChangePublisher() -> some Publisher<Profile?, Never> {
        auth.authStateDidChangePublisher()
            .map { user in
                user.map { Profile(userType: .coach, firstName: "", lastName: "", email: $0.email!) }
            }
    }
    
    func signIn(email: String, password: String) async -> Bool {
        do {
            try await auth.signIn(withEmail: email, password: password)
            return true
        } catch {
            print("SignIn error : \(String(describing: error))")
            return false
        }
    }
    
//    func signUp(email: String, password: String, userType: UserType, firstName: String, lastName: String) async -> Bool {
        func signUp(email: String, password: String) async -> Bool {
        do {
           try await auth.createUser(withEmail: email, password: password)
            
            return true
        } catch {
            print("SignUp error : \(String(describing: error))")
            return false
        }
    }
    
//    func updateUser() {
//        let user = auth.currentUser
//        user.
//    }
    
    func signOut() -> Bool {
        do {
            try auth.signOut()
            return true
        } catch {
            print("SignOut error : \(String(describing: error))")
            return false
        }
    }
    
    func deleteCurrentUser() async -> Bool {
        return await withCheckedContinuation { continuation in
            guard let user = auth.currentUser else {
                continuation.resume(returning: false)
                return
            }
            
            user.delete { error in
                if let error = error {
                    print("Delete current user error : \(String(describing: error))")
                    continuation.resume(returning: false)
                } else {
                    continuation.resume(returning: true)
                }
            }
        }
    }
}
