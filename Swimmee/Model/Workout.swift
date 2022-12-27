//
//  Workout.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import Foundation

// Workouts are created and published by coach to be used by swimmers of their team

struct Workout: Identifiable, Codable, DbIdentifiable, Hashable {
    typealias DbId = String
    
    private enum CodingKeys: CodingKey {
        case dbId, userId, date, duration, title, content, isSent
    }
    
    var dbId: DbId? // Database object identifier
    var id = UUID() // Dedicated to SwiftUI view identity system
    var userId: UserId // Uniquely identifies the owner user
    var date: Date
    var duration: Int
    var title: String
    var content: String
    var isSent: Bool
    
    init(dbId: DbId? = nil, userId: UserId, date: Date = .dateNow, duration: Int = 90, title: String = "", content: String = "", isSent: Bool = false) {
        self.dbId = dbId
        self.userId = userId
        self.date = date
        self.duration = duration
        self.title = title
        self.content = content
        self.isSent = isSent
    }
    
    var isNew: Bool { dbId == nil }
    
    func hasContentDifferent(from workout: Workout) -> Bool {
        workout.title != title
        || workout.content != content
        || workout.date != date
        || workout.duration != duration
    }
    
    var tagsCache: Set<Int> = []
}
