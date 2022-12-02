//
//  MainView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 06/10/2022.
//

import Combine
import SwiftUI

class Session: ObservableObject {
    let accountAPI: AccountAPI

    init(accountAPI: AccountAPI = FirebaseAccountAPI()) {
        print("Session.init")
        self.accountAPI = accountAPI
    }

    @Published var connectionStatus = AccountSignedState.undefined {
        didSet {
//            print("session.onnectionStatus didSet with \(connectionStatus)")
            if case .failure(let error) = connectionStatus {
                errorAlertMessage = error.localizedDescription
//                errorAlertOkButtonCompletion = { self.connectionStatus = .signedOut }
            }
        }
    }

    @Published var errorAlertIsPresenting = false {
        didSet {
            if errorAlertIsPresenting == false {
                errorAlertMessage = ""
//                errorAlertOkButtonCompletion = {}
            }
        }
    }

    func errorAlertOkButtonCompletion()  {
        _ = accountAPI.signOut()
    }

    var errorAlertMessage: String = "" {
        didSet {
            if !errorAlertMessage.isEmpty {
                errorAlertIsPresenting = true
            }
        }
    }

    func updateSignedStatus(_ newStatus: AccountSignedState) {
//        print("session.updateSignedInState")
        switch (connectionStatus, newStatus) {
        case (.signedIn(let profile), .signedIn(let newProfile)) where profile.userId != newProfile.userId:
            fatalError("session.updateSignedInState: user has changed (impossible state")

        case (.undefined, .undefined),
             (.signedOut, .signedOut),
             (.failure(_), .failure(_)),
             (.signedIn(_), .signedIn(_)):
//            print("session.updateSignedInState: Nothing has changed")
            ()

        default:
            connectionStatus = newStatus
        }
    }
}

struct MainView: View {
    @StateObject var session = Session()

    var body: some View {
        Group {
            switch session.connectionStatus {
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
        .onReceive(session.accountAPI.signedStatePublisher(), perform: session.updateSignedStatus)
        .alert(session.errorAlertMessage, isPresented: $session.errorAlertIsPresenting) {
            Button("OK", action: session.errorAlertOkButtonCompletion)
        }
    }
}

//struct MainView_Previews: PreviewProvider {
//    class ConnectionService: ConnectionServiceProtocol {
//        var connectionStatus: ConnectionStatus
//        init(connectionStatus: ConnectionStatus) {
//            self.connectionStatus = connectionStatus
//        }
//
//        func statusPublisher() -> AnyPublisher<ConnectionStatus, Never> {
//            //        Just(connectionStatus).eraseToAnyPublisher()
//            //        CurrentValueSubject(connectionStatus).eraseToAnyPublisher()
//            Array(repeating: connectionStatus, count: 3).publisher.print("connectionStatusPublisher").eraseToAnyPublisher()
//        }
//    }
//
//    static func sampleSession(connectionStatus: ConnectionStatus) -> Session {
//        let connectionService = ConnectionService(connectionStatus: connectionStatus)
//        let session = Session(connectionService: connectionService)
//        session.connectionStatus = connectionStatus // TODO:
//        return session
//    }
//
//    static var previews: some View {
////        MainView(session: Session(accountManager: FakeAccountManager(connectionStatus: .undefined)))
////        MainView(session: Session(accountManager: FakeAccountManager(connectionStatus: .signedOut)))
//        MainView(session: sampleSession(connectionStatus: .failure(FakeAccountManager.Err.signInError)))
////        MainView(session: Session(accountManager: FakeAccountManager(connectionStatus: .signedIn(Profile.coachSample))))
////        MainView(session: Session(accountManager: FakeAccountManager(connectionStatus: .failure(FakeAccountManager.Err.signInError))))
//    }
//}
