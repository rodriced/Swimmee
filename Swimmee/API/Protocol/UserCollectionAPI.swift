//
//  CollectionAPI.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 05/12/2022.
//

import Foundation

protocol DbIdentifiable: Codable {
    var dbId: String? { get set }
}
