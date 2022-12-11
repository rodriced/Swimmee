//
//  Samples.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 11/12/2022.
//

@testable import Swimmee

import Foundation

class Samples {
    static let aCoachProfile = Profile(userId: "", userType: .coach, firstName: "aFirstName", lastName: "aLastName", email: "an@e.mail")
    static let aSwimmerProfile = Profile(userId: "", userType: .swimmer, firstName: "aFirstName", lastName: "aLastName", email: "an@e.mail")
    
    static let aTeam = (1...5).map {
        Profile(userId: "\($0)", userType: .swimmer, firstName: "aFirstName\($0)", lastName: "aLastName\($0)", email: "an\($0)@e.mail")
    }
}
