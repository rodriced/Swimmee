//
//  Service.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 17/10/2022.
//

import Foundation

class Service {
//    private init() {}
    static var shared = Service()

    var auth: FirebaseAuthService

    init(auth: FirebaseAuthService = FirebaseAuthService()) {
        self.auth = auth
    }
}
