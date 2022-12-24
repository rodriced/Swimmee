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
    var mockSignUp: () throws -> Profile = { BadContextCallInMockFail(); fatalError() }
    var mockDeleteCurrrentAccount: () throws -> Void = { BadContextCallInMockFail(); fatalError() }
    var mockSignIn: () throws -> Profile = { BadContextCallInMockFail(); fatalError() }
    var mockReauthenticate: () throws -> Void = { BadContextCallInMockFail(); fatalError() }
    var mockSignOut: () -> Bool = { BadContextCallInMockFail(); fatalError() }
    var mockUpdateEmail: (String) async throws -> Void = { _ in BadContextCallInMockFail(); fatalError() }

    var currentUserId: UserId? { currentProfile?.userId }

    func AuthenticationStatePublisher() -> AnyPublisher<AuthenticationState, Never> {
        $currentProfile.map { profile in
            guard let profile else { return AuthenticationState.signedOut }
            return AuthenticationState.signedIn(profile)
        }
        .eraseToAnyPublisher()
    }

    var accounts: [String: String] = [:]
    var profiles: [String: Profile] = [:]
    @Published var currentProfile: Profile?

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
