//
//  DbIdentifiable.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 26/12/2022.
//

import Foundation

// DbIdentifiable is a protocol apply to a stored object property
// that will permit to identfy it in database

protocol DbIdentifiable: Codable {
    var dbId: String? { get set }
}
