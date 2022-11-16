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
    var id: UUID
    var userId: String
    var date: Date
    var title: String
    var content: String
    var isSended: Bool
    
    init(dbId: String? = nil, id: UUID = UUID(), userId: String, date: Date = .now, title: String = "", content: String = "", isSended: Bool = false) {
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
