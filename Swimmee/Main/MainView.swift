//
//  MainView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 06/10/2022.
//

import Combine
import SwiftUI

var c = 0

class Session: ObservableObject {
    let accountAPI: AccountAPI

    init(accountAPI: AccountAPI = FirebaseAccountAPI()) {
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

struct MainView: View {
    @StateObject var session = Session()

    var body: some View {
        Group {
            switch session.authenticationState {
            case .undefined:
                ProgressView()
            case .signedOut:
                NavigationView {
                    SignUpView()
                }
            case .signedIn(let initialProfile):
                SignedInView(profile: initialProfile)
            case .failure:
//                Text(error.localizedDescription)
                Color.clear
            }
//                .navigationViewStyle(.stack)
        }
        .onReceive(session.accountAPI.AuthenticationStatePublisher(), perform: session.updateAuthenticationState)
        .alert(session.authenticationFailureAlert) {
            Button("OK", action: session.errorAlertOkButtonCompletion)
        }
    }
}

// struct MainView_Previews: PreviewProvider {
//    class ConnectionService: ConnectionServiceProtocol {
//        var authenticationState: ConnectionStatus
//        init(authenticationState: ConnectionStatus) {
//            self.authenticationState = authenticationState
//        }
//
//        func statusPublisher() -> AnyPublisher<ConnectionStatus, Never> {
//            //        Just(authenticationState).eraseToAnyPublisher()
//            //        CurrentValueSubject(authenticationState).eraseToAnyPublisher()
//            Array(repeating: authenticationState, count: 3).publisher.print("connectionStatusPublisher").eraseToAnyPublisher()
//        }
//    }
//
//    static func sampleSession(authenticationState: ConnectionStatus) -> Session {
//        let connectionService = ConnectionService(authenticationState: authenticationState)
//        let session = Session(connectionService: connectionService)
//        session.authenticationState = authenticationState // TODO:
//        return session
//    }
//
//    static var previews: some View {
////        MainView(session: Session(accountManager: FakeAccountManager(authenticationState: .undefined)))
////        MainView(session: Session(accountManager: FakeAccountManager(authenticationState: .signedOut)))
//        MainView(session: sampleSession(authenticationState: .failure(FakeAccountManager.Err.signInError)))
////        MainView(session: Session(accountManager: FakeAccountManager(authenticationState: .signedIn(Profile.coachSample))))
////        MainView(session: Session(accountManager: FakeAccountManager(authenticationState: .failure(FakeAccountManager.Err.signInError))))
//    }
// }
