//
//  ConnectionService.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 08/11/2022.
//

//import Foundation
import Combine

public enum ConnectionStatus: Equatable {
    public static func == (lhs: ConnectionStatus, rhs: ConnectionStatus) -> Bool {
        switch (lhs, rhs) {
        case (.signedIn(let lhsProfile), .signedIn(let rhsProfile)) where lhsProfile.userId == rhsProfile.userId:
            return true
        case (.undefined, .undefined),
             (.signedOut, .signedOut),
            (.failure(_), .failure(_)):
            return true
    
        default:
            return false
        }
    }
    
    case undefined
    case signedOut
    case signedIn(Profile)
    case failure(Error)
    
    var profile: Profile? {
        switch self {
        case let .signedIn(profile):
            return profile
        default:
            return nil
        }
    }
}

public protocol ConnectionServiceProtocol {
    func statusPublisher() -> AnyPublisher<ConnectionStatus, Never>
}

class ConnectionService: ConnectionServiceProtocol {
    func statusPublisher() -> AnyPublisher<ConnectionStatus, Never> {
        API.shared.auth.currentUserIdPublisher()
            .flatMap { userId -> AnyPublisher<ConnectionStatus, Never> in
                guard let userId = userId else {
//                    print("Account.signedInStateChangePublisher : not logged in")
                    return Just(ConnectionStatus.signedOut) // cast needed
                        .eraseToAnyPublisher()
                }
                return API.shared.profile.future(userId: userId)
                    .map {profile in
//                        print("Account.signedInStateChangePublisher : logged in (Profile found)")
                        return ConnectionStatus.signedIn(profile) // cast needed
                    }
                    .catch { error -> Just<ConnectionStatus> in
//                        print("Account.signedInStateChangePublisher : abort log in (Profile not found). Error : \(error.localizedDescription)")
                        return Just(ConnectionStatus.failure(error))
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
