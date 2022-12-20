//
//  Session.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 06/10/2022.
//

import Combine

class Session: ObservableObject {
    let accountAPI: AccountAPI

    init(accountAPI: AccountAPI = API.shared.account) {
        print("Session.init")
        self.accountAPI = accountAPI
    }

    @Published var authenticationFailureAlert = AlertContext()

    @Published var authenticationState = AuthenticationState.undefined {
        didSet {
            if case .failure(let error) = authenticationState {
                authenticationFailureAlert.message = error.localizedDescription
            }
        }
    }

    func errorAlertOkButtonCompletion() {
        _ = accountAPI.signOut()
    }

    func updateAuthenticationState(_ newState: AuthenticationState) {
//        print("session.updateSignedInState")
        switch (authenticationState, newState) {
        case (.signedIn(let profile), .signedIn(let newProfile)) where profile.userId != newProfile.userId:
            fatalError("session.updateSignedInState: user has changed (impossible state")

        case (.undefined, .undefined),
             (.signedOut, .signedOut),
             (.failure(_), .failure(_)),
             (.signedIn(_), .signedIn(_)):
//            print("session.updateSignedInState: Nothing has changed")
            ()

        default:
            authenticationState = newState
        }
    }
}
