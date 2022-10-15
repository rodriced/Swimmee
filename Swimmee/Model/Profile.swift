//
//  Profile.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import Foundation

enum UserType: String, CaseIterable, Identifiable {
    var id: Self { self }

    case coach, swimmer
}

struct Profile: Identifiable, Hashable {
    let id = UUID()
    let userType: UserType
    var firstName: String
    var lastName: String
    var email: String

    var fullname: String {
        "\(firstName) \(lastName)"
    }

    static let coachSample = Profile(userType: .swimmer, firstName: "Laurent", lastName: "Dupont", email: "laurent.dupont@ggmail.com")

    static let swimmerSample = Profile(userType: .coach, firstName: "Laurent", lastName: "Dupont", email: "laurent.dupont@ggmail.com")

    func toSamples(with nbElements: Int) -> [Profile] {
        (1 ... nbElements).map {
            Profile(userType: userType, firstName: firstName + String($0), lastName: lastName, email: email)
        }
    }
}
