//
//  Message.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import Foundation

struct Workout: Identifiable, Codable, DbIdentifiable, Hashable {
    typealias DbId = String
    
    private enum CodingKeys: CodingKey {
        case dbId, userId, date, duration, title, content, isSent
    }
    
    var dbId: DbId?
    var id = UUID()
    var userId: UserId
    var date: Date
    var duration: Int
    var title: String
    var content: String
    var isSent: Bool
    
    init(dbId: DbId? = nil, userId: UserId, date: Date = .now, duration: Int = 90, title: String = "", content: String = "", isSent: Bool = false) {
        self.dbId = dbId
        self.userId = userId
        self.date = date
        self.duration = duration
        self.title = title
        self.content = content
        self.isSent = isSent
    }
    
    func hasTextDifferent(from workout: Workout) -> Bool {
        workout.title != title || workout.content != content
    }
    
    static var sample = Workout(userId: UUID().uuidString, title: "Workout", content: "100m free\n200m ...")
    
    func toSamples(_ nbElements: Int) -> [Workout] {
        (1 ... nbElements).map {
            Workout(userId: UUID().uuidString, title: title + String($0), content: content)
        }
    }

}
