//
//  Profile.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import Foundation

public enum UserType: String, CaseIterable, Identifiable, Codable {
    public var id: Self { self }

    case coach, swimmer
    
    var isCoach: Bool {self == .coach}
    var isSwimmer: Bool {self == .swimmer}
}

public struct Profile: Identifiable, Hashable, Codable, DbIdentifiable, Equatable {
//        static func == (lhs: Self, rhs: Self) -> Bool {
//            lhs.userId == rhs.userId
//        }

    var dbId: String?
    public var id = UUID()
    var userId: String
    let userType: UserType
    var firstName: String
    var lastName: String
    var email: String
    var photoUrl: URL?
    var coachId: String?

    var fullname: String {
        "\(firstName) \(lastName)"
    }
    
    init(userId: String, userType: UserType, firstName: String, lastName: String, email: String) {
        self.userId = userId
        self.userType = userType
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }

    static let coachSample = Profile(userId: UUID().uuidString, userType: .swimmer, firstName: "Laurent", lastName: "Dupont", email: "laurent.dupont@ggmail.com")

    static let swimmerSample = Profile(userId: UUID().uuidString, userType: .coach, firstName: "Laurent", lastName: "Dupont", email: "laurent.dupont@ggmail.com")

    func toSamples(with nbElements: Int) -> [Profile] {
        (1 ... nbElements).map {
            Profile(userId: UUID().uuidString, userType: userType, firstName: firstName + String($0), lastName: lastName, email: email)
        }
    }
}
