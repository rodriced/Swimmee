//
//  Session.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 06/10/2022.
//


import Combine

// Session is the view model of the main view.
// It manage the state (SessionState) of the whole application, mainly the authentication state
// with a particular state when the user delete his account.

enum SessionState: Equatable {
    case undefined, signedIn(Profile), signedOut, failure(Error), deletingAccount, accountDeleted

    static func == (lhs: SessionState, rhs: SessionState) -> Bool {
        switch (lhs, rhs) {
        case (.signedIn(let lhsProfile), .signedIn(let rhsProfile)) where lhsProfile.userId == rhsProfile.userId:
            // 2 users are considered different if they do not have the same userId
            return true

        case (.undefined, .undefined),
             (.signedOut, .signedOut),
             (.failure(_), .failure(_)),
             (.deletingAccount, .deletingAccount),
             (.accountDeleted, .accountDeleted):
            return true

        default:
            return false
        }
    }

    var isFailure: Bool {
        if case .failure = self { return true }
        return false
    }
}

class Session: ObservableObject {
    private let accountAPI: AccountAPI
    private let profileAPI: ProfileCommonAPI

    @Published var state = SessionState.undefined
    @Published var stateFailureAlert = AlertContext()

    init(accountAPI: AccountAPI = API.shared.account,
         profileAPI: ProfileCommonAPI = API.shared.profile)
    {
        self.accountAPI = accountAPI
        self.profileAPI = profileAPI
    }

    // MARK: - Session state workflow managed by publishers

    var cancellable: AnyCancellable?

    func startStateWorkflow() {
        
        // When state is .failure then alert message will contain the error description
        cancellable = $state
            .filter(\.isFailure)
            .flatMap {
                if case .failure(let error) = $0 {
                    return Just(error.localizedDescription).eraseToAnyPublisher()
                }
                return Empty().eraseToAnyPublisher()
            }
            .sink { self.stateFailureAlert.message = $0 }

        // State main workflow (authentication and account deletion)
        accountAPI.currentUserIdPublisher()
            .flatMap { userId in
                switch (self.state, userId) {
                //
                // Abnormal behaviour //
                // ------------------//
                case (.signedIn(let profile), .some(let userId)) where profile.userId != userId:
                    // Normaly impossible case : user replaced by another in the same session !
                    return Just(SessionState.failure(AccountError.userReplacedByAnother))
                        .eraseToAnyPublisher()

                // Account deletion workflow //
                // ---------------------------//
                case (.deletingAccount, .none): // Profile does not exist anymore
                    // so it's the end of the delete account process
                    return Just(SessionState.accountDeleted)
                        .eraseToAnyPublisher()

                case (.deletingAccount, .some), // Account deletion process in progress
                     (.accountDeleted, _): // End of the account deletion. Next state will be .signOut
                    return Empty(completeImmediately: false, outputType: SessionState.self, failureType: Never.self)
                        .eraseToAnyPublisher()

                // Normal workflow //
                // -----------------//
                case (_, .none):
                    return Just(SessionState.signedOut)
                        .eraseToAnyPublisher()

                case (_, .some(let userId)):
                    return self.profileAPI.future(userId: userId)
                        .map(SessionState.signedIn)
                        .catch { _ in
                            Just(SessionState.failure(AccountError.profileLoadingError))
                        }
                        .eraseToAnyPublisher()
                }
            }
            .equatableAssign(to: &$state)
    }

    // When unrecoverable Error happens, user is logged out to prevent possible data corruption
    func abort() {
        _ = accountAPI.signOut()
    }

    // MARK: -- Account deletion management
    
    func deleteCurrentAccount() {
        state = .deletingAccount

        Task {
            do {
                try await accountAPI.deleteCurrrentAccount()
                // when the user account is finaly deleted, it triggers the publication of new auth id with a nil value.
                // Then the state will get automatically the value .acccountDeleted
            } catch {
                state = .failure(error)
            }
        }
    }

    func accountDeletionCompletion() {
        state = .signedOut
    }
}
