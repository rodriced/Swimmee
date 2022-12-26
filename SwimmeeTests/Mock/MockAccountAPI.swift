//
//  MockAccountManager.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 01/12/2022.
//

@testable import Swimmee

import Combine
import Foundation

class MockAccountAPI: AccountAPI {
    var mockCurrentUserIdPublisher: () -> AnyPublisher<UserId?, Never> = { MockFunctionNotInitialized(); fatalError() }

    var mockSignUp: () throws -> Profile = { MockFunctionNotInitialized(); fatalError() }
    var mockDeleteCurrrentAccount: () throws -> Void = { MockFunctionNotInitialized(); fatalError() }
    var mockSignIn: () throws -> Profile = { MockFunctionNotInitialized(); fatalError() }
    var mockReauthenticate: () throws -> Void = { MockFunctionNotInitialized(); fatalError() }
    var mockSignOut: () -> Bool = { MockFunctionNotInitialized(); fatalError() }
    var mockUpdateEmail: (String) async throws -> Void = { _ in MockFunctionNotInitialized(); fatalError() }

    var currentUserId: UserId? { currentProfile?.userId }

//    func AuthenticationStatePublisher() -> AnyPublisher<AuthenticationState, Never> {
//        $currentProfile.map { profile in
//            guard let profile else { return AuthenticationState.signedOut }
//            return AuthenticationState.signedIn(profile)
//        }
//        .eraseToAnyPublisher()
//    }

    var accounts: [String: String] = [:]
    var profiles: [String: Profile] = [:]
    @Published var currentProfile: Profile?

    func currentUserIdPublisher() -> AnyPublisher<UserId?, Never> {
        mockCurrentUserIdPublisher()
    }

    func signUp(email: String, password: String, userType: UserType, firstName: String, lastName: String) async throws -> Profile {
        let profile = try mockSignUp()
        currentProfile = profile
        return profile
    }

    func deleteCurrrentAccount() async throws {
        try mockDeleteCurrrentAccount()
    }

    func signIn(email: String, password: String) async throws -> Profile {
        let profile = try mockSignIn()
        currentProfile = profile
        return profile
    }

    func reauthenticate(email: String, password: String) async throws {
        try mockReauthenticate()
    }

    func signOut() -> Bool {
        if mockSignOut() {
            currentProfile = nil
            return true
        }
        return false
    }

    func updateEmail(to newEmail: String) async throws {
        try await mockUpdateEmail(newEmail)
    }
}
