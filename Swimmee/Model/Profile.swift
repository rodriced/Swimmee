//
//  Profile.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import Foundation

typealias UserId = String

public enum UserType: String, CaseIterable, Identifiable, Codable {
    public var id: Self { self }

    case coach, swimmer

    var isCoach: Bool { self == .coach }
    var isSwimmer: Bool { self == .swimmer }
}

public struct PhotoInfo: Hashable, Codable, Equatable {
    let url: URL, size: Int, hash: Int
    
    init(url: URL, data: Data) {
        self.url = url
        self.size = data.count
        self.hash = data.hashValue
    }
    
    public static func == (lhs: PhotoInfo, rhs: PhotoInfo) -> Bool {
        lhs.size == rhs.size && lhs.hash == rhs.hash
    }
}

public struct Profile: Identifiable, Hashable, Codable, DbIdentifiable, Equatable {
    typealias DbId = String

    enum CodingKeys: CodingKey {
        case id, userId, userType, firstName, lastName, email, photoInfo, coachId, readWorkoutsIds, readMessagesIds
    }

    var dbId: DbId?
    public var id: UUID
    var userId: UserId
    let userType: UserType

    var firstName: String
    var lastName: String
    var email: String
    var photoInfo: PhotoInfo?

    var coachId: UserId?

    var readWorkoutsIds: Set<Message.DbId>?
    var readMessagesIds: Set<Message.DbId>?

    var fullname: String {
        "\(firstName) \(lastName)"
    }

    init(id: UUID = UUID(), userId: String, userType: UserType, firstName: String, lastName: String, email: String, readWorkoutsIds: Set<DbId> = [],readMessagesIds: Set<DbId> = []) {
        self.id = id
        self.userId = userId
        self.userType = userType
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.readWorkoutsIds = readWorkoutsIds
        self.readMessagesIds = readMessagesIds
    }
}
