//
//  Message.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import Foundation
import FirebaseFirestoreSwift

struct Message: Identifiable, Codable, DbIdentifiable {
    var dbId: String?
    var id = UUID()
    var userId: String
    var date: Date = .now
    var title: String
    var content: String
    var isUnread: Bool
    var isSended: Bool = false
    
    init(dbId: String? = nil, id: UUID = UUID(), userId: String, date: Date = .now, title: String = "", content: String = "", isUnread: Bool) {
        self.dbId = dbId
        self.id = id
        self.userId = userId
        self.date = date
        self.title = title
        self.content = content
        self.isUnread = isUnread
    }
    
    static var sample = Message(userId: UUID().uuidString, title: "Message", content: "Bla bla bla\nBlalbla blaaaaaa", isUnread: true)
    
    func toSamples(_ nbElements: Int) -> [Message] {
        (1 ... nbElements).map {
            Message(userId: UUID().uuidString, title: title + String($0), content: content, isUnread: isUnread)
        }
    }
}
