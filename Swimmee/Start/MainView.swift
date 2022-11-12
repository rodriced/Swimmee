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
        didSet { debugPrint("session.onnectionStatus didSet with \(connectionStatus)")
            if case .failure(let error) = connectionStatus {
                errorAlertMessage = error.localizedDescription
//                errorAlertOkButtonCompletion = { self.connectionStatus = .loggedOut }
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
        print("session.updateSignedInState")
        switch (connectionStatus, newStatus) {
        case (.loggedIn(let profile), .loggedIn(let newProfile)) where profile.userId != newProfile.userId:
            fatalError("session.updateSignedInState: user has changed (impossible state")

        case (.undefined, .undefined),
             (.loggedOut, .loggedOut),
             (.failure(_), .failure(_)),
             (.loggedIn(_), .loggedIn(_)):
            print("session.updateSignedInState: Nothing has changed")

        default:
            connectionStatus = newStatus
        }
    }
}

class UserSession: ObservableObject {
    let userId: String
    let userType: UserType

    init(userId: UserId, userType: UserType) {
        self.userId = userId
        self.userType = userType
    }

    convenience init(profile: Profile) {
        self.init(userId: profile.userId, userType: profile.userType)
//        self.userId = profile.userId
//        self.userType = profile.userType
    }

    var isCoach: Bool { userType == .coach }
    var isSwimmer: Bool { userType == .swimmer }
}

struct MainView: View {
    @StateObject var session = Session()

    var body: some View {
        Group {
            switch session.connectionStatus {
            case .undefined:
                ProgressView()
            case .loggedOut:
                NavigationView {
                    SignUpView()
                }
            case .loggedIn(let profile):
                SignedInView()
                    .environmentObject(UserSession(profile: profile))
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
//        MainView(session: Session(accountManager: MockedAccountManager(connectionStatus: .loggedOut)))
        MainView(session: sampleSession(connectionStatus: .failure(MockedAccountManager.Err.signInError)))
//        MainView(session: Session(accountManager: MockedAccountManager(connectionStatus: .loggedIn(Profile.coachSample))))
//        MainView(session: Session(accountManager: MockedAccountManager(connectionStatus: .failure(MockedAccountManager.Err.signInError))))
    }
}
