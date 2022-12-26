//
//  Message.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import Foundation

// Messages are created by coach to give some informations to the swimmers of their team

struct Message: Identifiable, Codable, DbIdentifiable, Hashable {
    typealias DbId = String
    
    private enum CodingKeys: CodingKey {
        case dbId, userId, date, title, content, isSent
    }
    
    var dbId: DbId? // Database object identifier
    var id = UUID() // Dedicated to SwiftUI view identity system
    var userId: UserId // Uniquely identifies the owner user
    var date: Date
    var title: String
    var content: String
    var isSent: Bool
    
    init(dbId: DbId? = nil, userId: UserId, date: Date = .now, title: String = "", content: String = "", isSent: Bool = false) {
        self.dbId = dbId
        self.userId = userId
        self.date = date
        self.title = title
        self.content = content
        self.isSent = isSent
    }
    
    var isNew: Bool { dbId == nil }
    
    func hasTextDifferent(from message: Message) -> Bool {
        message.title != title || message.content != content
    }
}
