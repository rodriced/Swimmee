//
//  ValueValidation.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 28/11/2022.
//

import Foundation

class ValueValidation {
    static var emailPredicate = {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex)
    }()

//    static var emailPredicate = {
//        let firstpart = "[A-Z0-9a-z]([A-Z0-9a-z._%+-]{0,30}[A-Z0-9a-z])?"
//        let serverpart = "([A-Z0-9a-z]([A-Z0-9a-z-]{0,30}[A-Z0-9a-z])?\\.){1,5}"
//        let emailRegex = firstpart + "@" + serverpart + "[A-Za-z]{2,64}"
//        return NSPredicate(format: "SELF MATCHES %@", emailRegex)
//    }()

    static func validateEmail(_ email: String) -> Bool {
        return Self.emailPredicate.evaluate(with: email)
    }

    static func validatePassword(_ password: String) -> Bool {
        password.count >= 6
    }

    static func validateFirstName(_ firstName: String) -> Bool {
        firstName.count >= 2
    }

    static func validateLastName(_ lastName: String) -> Bool {
        lastName.count >= 2
    }
}
