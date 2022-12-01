//
//  MainView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 06/10/2022.
//

import Combine
import SwiftUI

class Session: ObservableObject {
    let connectionService: ConnectionServiceProtocol

    init(connectionService: ConnectionServiceProtocol = ConnectionService()) {
        print("Session.init")
        self.connectionService = connectionService
    }

    @Published var connectionStatus = ConnectionStatus.undefined {
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

    var errorAlertOkButtonCompletion: () -> Void = {}

    var errorAlertMessage: String = "" {
        didSet {
            if !errorAlertMessage.isEmpty {
                errorAlertIsPresenting = true
            }
        }
    }

    func updateConnectionStatus(_ newStatus: ConnectionStatus) {
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
        .onReceive(session.connectionService.statusPublisher(), perform: session.updateConnectionStatus)
        .alert(session.errorAlertMessage, isPresented: $session.errorAlertIsPresenting) {
            Button("OK", action: session.errorAlertOkButtonCompletion)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    class ConnectionService: ConnectionServiceProtocol {
        var connectionStatus: ConnectionStatus
        init(connectionStatus: ConnectionStatus) {
            self.connectionStatus = connectionStatus
        }

        func statusPublisher() -> AnyPublisher<ConnectionStatus, Never> {
            //        Just(connectionStatus).eraseToAnyPublisher()
            //        CurrentValueSubject(connectionStatus).eraseToAnyPublisher()
            Array(repeating: connectionStatus, count: 3).publisher.print("connectionStatusPublisher").eraseToAnyPublisher()
        }
    }

    static func sampleSession(connectionStatus: ConnectionStatus) -> Session {
        let connectionService = ConnectionService(connectionStatus: connectionStatus)
        let session = Session(connectionService: connectionService)
        session.connectionStatus = connectionStatus // TODO:
        return session
    }

    static var previews: some View {
//        MainView(session: Session(accountManager: MockedAccountManager(connectionStatus: .undefined)))
//        MainView(session: Session(accountManager: MockedAccountManager(connectionStatus: .signedOut)))
        MainView(session: sampleSession(connectionStatus: .failure(MockedAccountManager.Err.signInError)))
//        MainView(session: Session(accountManager: MockedAccountManager(connectionStatus: .signedIn(Profile.coachSample))))
//        MainView(session: Session(accountManager: MockedAccountManager(connectionStatus: .failure(MockedAccountManager.Err.signInError))))
    }
}
