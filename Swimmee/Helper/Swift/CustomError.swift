//
//  CustomError.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 02/12/2022.
//

import Foundation

protocol CustomError: LocalizedError, CustomStringConvertible {}

extension CustomError {
    var errorDescription: String? {
        return description
    }
}
