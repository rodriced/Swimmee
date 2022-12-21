//
//  Samples.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 21/12/2022.
//

import Foundation

extension Profile {
    static let coachSample = Profile(userId: UUID().uuidString, userType: .swimmer, firstName: "Laurent", lastName: "Dupont", email: "laurent.dupont@ggmail.com")

    static let swimmerSample = Profile(userId: UUID().uuidString, userType: .coach, firstName: "Laurent", lastName: "Dupont", email: "laurent.dupont@ggmail.com")

    func toSamples(with nbElements: Int) -> [Profile] {
        (1 ... nbElements).map {
            Profile(userId: UUID().uuidString, userType: userType, firstName: firstName + String($0), lastName: lastName, email: email)
        }
    }
}

extension Workout {
    static var sample = Workout(userId: UUID().uuidString, title: "Workout", content: "100m free\n200m ...")
    
    func toSamples(_ nbElements: Int) -> [Workout] {
        (1 ... nbElements).map { ref in
            Workout(dbId: dbId.map { "\($0)_\(ref)" }, userId: UUID().uuidString, title: "\(title)\(ref)", content: content)
        }
    }
}

extension Message {
    static var sample = Message(userId: UUID().uuidString, title: "Message", content: "Bla bla bla\nBlalbla blaaaaaa")
    
    func toSamples(_ nbElements: Int) -> [Message] {
        (1 ... nbElements).map { ref in
            Message(dbId: dbId.map { "\($0)_\(ref)" }, userId: UUID().uuidString, title: "\(title)\(ref)", content: content)
        }
    }
}
