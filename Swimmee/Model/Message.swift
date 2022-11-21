//
//  Message.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import FirebaseFirestoreSwift
import Foundation

struct Message: Identifiable, Codable, DbIdentifiable {
    typealias DbId = String
    
    private enum CodingKeys: CodingKey {
        case dbId, id, userId, date, title, content, isSended
    }
    
    var dbId: DbId?
    var id: UUID
    var userId: UserId
    var date: Date
    var title: String
    var content: String
    var isSended: Bool
    var isRead = false
    
    init(dbId: DbId? = nil, id: UUID = UUID(), userId: UserId, date: Date = .now, title: String = "", content: String = "", isSended: Bool = false) {
        self.dbId = dbId
        self.id = id
        self.userId = userId
        self.date = date
        self.title = title
        self.content = content
        self.isSended = isSended
    }
    
    static var sample = Message(userId: UUID().uuidString, title: "Message", content: "Bla bla bla\nBlalbla blaaaaaa")
    
    func toSamples(_ nbElements: Int) -> [Message] {
        (1 ... nbElements).map {
            Message(userId: UUID().uuidString, title: title + String($0), content: content)
        }
    }
}
