//
//  ValueValidation.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 28/11/2022.
//

import Foundation

class ValueValidation {
    static func validateEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
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

    static func validatePhoto(_ photo: PhotoInfo) -> Bool {
        true
    }
}
