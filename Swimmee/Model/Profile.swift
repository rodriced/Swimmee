//
//  Profile.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import Foundation

public enum UserType: String, CaseIterable, Identifiable, Codable {
    public var id: String { rawValue }

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
        case id, userId, userType, firstName, lastName, email, photoInfo, coachId, readMessagesIds
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
//    {
//        didSet {
//            if coachId != oldValue {
//                readMessagesIds = []
//            }
//        }
//    }
    var readMessagesIds: Set<Message.DbId>?

    var fullname: String {
        "\(firstName) \(lastName)"
    }

    init(id: UUID = UUID(), userId: String, userType: UserType, firstName: String, lastName: String, email: String, readMessagesIds: Set<DbId> = []) {
        self.id = id
        self.userId = userId
        self.userType = userType
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.readMessagesIds = readMessagesIds
    }

    static let coachSample = Profile(userId: UUID().uuidString, userType: .swimmer, firstName: "Laurent", lastName: "Dupont", email: "laurent.dupont@ggmail.com")

    static let swimmerSample = Profile(userId: UUID().uuidString, userType: .coach, firstName: "Laurent", lastName: "Dupont", email: "laurent.dupont@ggmail.com")

    func toSamples(with nbElements: Int) -> [Profile] {
        (1 ... nbElements).map {
            Profile(userId: UUID().uuidString, userType: userType, firstName: firstName + String($0), lastName: lastName, email: email)
        }
    }
}

// extension Profile: Decodable {
//    public init(from decoder: Decoder) throws {
////        do {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        id = try values.decode(UUID.self, forKey: .id)
//        userId = try values.decode(UserId.self, forKey: .userId)
//        userType = try values.decode(UserType.self, forKey: .userType)
//        firstName = try values.decode(String.self, forKey: .firstName)
//        lastName = try values.decode(String.self, forKey: .lastName)
//        email = try values.decode(String.self, forKey: .email)
//        photoUrl = try values.decode(URL?.self, forKey: .photoUrl)
//        coachId = try values.decode(UserId?.self, forKey: .coachId)
//        let readMessagesIdsArray = try values.decodeIfPresent([Message.DbId].self, forKey: .readMessagesIds)
////        print("readMessagesIdsArray = \(readMessagesIdsArray?.debugDescription)")
//        readMessagesIds = readMessagesIdsArray.map(Set.init) ?? []
//    }
// }

// extension Profile: Encodable {
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(dbId, forKey: .dbId)
//        try container.encode(id, forKey: .id)
//        try container.encode(userId, forKey: .userId)
//        try container.encode(userType, forKey: .userType)
//        try container.encode(firstName, forKey: .firstName)
//        try container.encode(lastName, forKey: .lastName)
//        try container.encode(email, forKey: .email)
//        try container.encode(photoUrl, forKey: .photoUrl)
//        try container.encode(coachId, forKey: .coachId)
//        try container.encode(Array(readMessagesIds), forKey: .readMessagesIds)
//    }
// }
