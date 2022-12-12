//
//  Samples.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 11/12/2022.
//

@testable import Swimmee

import Foundation

class Samples {
    static var aCoachProfile: Profile {
        Profile(userId: "", userType: .coach, firstName: "aFirstName", lastName: "aLastName", email: "an@e.mail")
    }

    static var aSwimmerProfile: Profile {
        Profile(userId: "", userType: .swimmer, firstName: "aFirstName", lastName: "aLastName", email: "an@e.mail")
    }

    static var aTeam: [Profile] {
        (1...5).map {
            Profile(userId: "\($0)", userType: .swimmer, firstName: "aFirstName\($0)", lastName: "aLastName\($0)", email: "an\($0)@e.mail")
        }
    }

    static var aCoachsList: [Profile] {
        (10...15).map {
            Profile(userId: "\($0)", userType: .coach, firstName: "aFirstName\($0)", lastName: "aLastName\($0)", email: "an\($0)@e.mail")
        }
    }
}
