//
//  ProfileAPI.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 06/12/2022.
//

import Foundation
import Combine

typealias ProfileAPI = ProfileCommonAPI & ProfileCoachAPI & ProfileSwimmerAPI & ProfileAccountAPI

protocol ProfileCommonAPI {
    func future(userId: String?) -> AnyPublisher<Profile, Error>
    func publisher(userId: String?) -> AnyPublisher<Profile, Error>
    func load(userId: String) async throws -> Profile
    func save(_ profile: Profile) async throws
}

protocol ProfileCoachAPI {
    func loadTeam() async throws -> [Profile]
}

protocol ProfileSwimmerAPI {
    func loadCoachs() async throws -> [Profile]
    func updateCoach(with coachId: String?) async throws
    func setMessageAsRead(_ messageDbId: Message.DbId) async throws
}

protocol ProfileAccountAPI {
    func delete(userId: String) async throws
}
