//
//  User.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import Foundation

struct User: Identifiable, Hashable {
    let id = UUID()
    let authId: String
    var email: String
    
    init(authId: String = UUID().uuidString, email: String) {
        self.authId = authId
        self.email = email
    }

    static let sample = User( email: "laurent.dupont@ggmail.com")

    func toSamples(with nbElements: Int) -> [User] {
        (1 ... nbElements).map {
            User(email: "n\($0)_\(email)")
        }
    }
}
