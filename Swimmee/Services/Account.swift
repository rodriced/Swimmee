//
//  Account.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 21/10/2022.
//

import Combine
import Foundation

class Account {
    enum AccountErr: Error { case profileSaveError(Error) }
    
    static func signUp(email: String, password: String, userType: UserType, firstName: String, lastName: String) async throws -> Profile {
        let userId = try await Service.shared.auth.signUp(email: email, password: password)
        let profile = Profile(userId: userId, userType: userType, firstName: firstName, lastName: lastName, email: email)
        do {
            try await Service.shared.store.saveProfile(profile: profile)
            return profile
        } catch {
            throw AccountErr.profileSaveError(error)
        }
    }
    
    static func deleteCurrrentAccount() async throws{
        try await Service.shared.auth.deleteCurrentUser()
        let userId = Service.shared.auth.currentUserId
        guard let userId = userId else {
            return
        }
        try await Service.shared.store.deleteProfile(userId: userId)
        try await Service.shared.storage.removePhoto(uid: userId)
    }

//    static func signedInUserProfilePublisher() -> AnyPublisher<Result<Profile?,Error>, Never> {
//        Service.shared.auth.signedInStateChangePublisher()
//            .flatMap { maybeUserId in
//                Future<Result<Profile?, Error>, Never> { promise in
//                    guard let userId = maybeUserId else {
//                        return promise(.success(.success(nil)))
//                    }
//
//                    Task {
//                        do {
//                            let profile = try await Service.shared.store.loadProfile(userId: userId)
//                            promise(.success(.success(profile)))
//                        } catch {
//                            promise(.success(.failure(error)))
//                        }
//                    }
//                }
//            }
//            .eraseToAnyPublisher()
//    }
    

//    static func signedInUserProfilePublisher() -> AnyPublisher<Result<Profile?,Error>, Never> {
//        Service.shared.auth.signedInStateChangePublisher()
//            .flatMap { maybeUserId in
//                Future<Result<Profile?, Error>, Never> { promise in
//                    guard let userId = maybeUserId else {
//                        return promise(.success(.success(nil)))
//                    }
//
//                    Task {
//                        do {
//                            let profile = try await Service.shared.store.loadProfile(userId: userId)
//                            promise(.success(.success(profile)))
//                        } catch {
//                            promise(.success(.failure(error)))
//                        }
//                    }
//                }
//            }
//            .eraseToAnyPublisher()
//    }
//
    
//    static func signedInUserProfilePublisher() -> AnyPublisher<Profile?, Never> {
//        Service.shared.auth.signedInStateChangePublisher()
//            .flatMap { maybeUserId in
//                Future<Profile?, Never> { promise in
//                    guard let userId = maybeUserId else {
//                        return promise(.success(nil))
//                    }
//
//                    Task {
//                        let profile = try? await Service.shared.store.loadProfile(userId: userId)
//                        promise(.success(profile))
//                    }
//                }
//            }
//            .eraseToAnyPublisher()
//    }

    
//    static func signedInUserProfilePublisher() -> AnyPublisher<Profile?, Error> {
//        Service.shared.auth.signedInStateChangePublisher()
//            .flatMap { maybeUserId in
//                return Future<Profile?, Error> { promise in
//                    guard let userId = maybeUserId else {
//                        return promise(.success(nil))
//                    }
//
//                    Task {
//                        do {
//                            let profile = try await Service.shared.store.loadProfile(userId: userId)
//                            promise(.success(profile))
//                        } catch {
//                            promise(.failure(error))
//                        }
//                    }
//                }
//            }
//            .eraseToAnyPublisher()
//    }
}
