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
    
    var isNew: Bool { dbId == nil }
    
    func hasTextDifferent(from workout: Workout) -> Bool {
        workout.title != title || workout.content != content
    }
    
    static var sample = Workout(userId: UUID().uuidString, title: "Workout", content: "100m free\n200m ...")
    
    func toSamples(_ nbElements: Int) -> [Workout] {
        (1 ... nbElements).map {
            Workout(userId: UUID().uuidString, title: title + String($0), content: content)
        }
    }

    var tagsCache: Set<Int> = []
}

extension Workout {
    static let allTags = ["backstroke", "breaststroke", "butterfly", "dolphin kick", "flutter kick", "freestyle", "frog kick", "medley", "relay"]
    
    static private func normalize(_ tag: String) -> String {
        tag.filter { !$0.isWhitespace }.lowercased()
    }
    
    static private var allNormalizedTags = allTags.map(normalize)
    
    static func updateTagsCache(for workout: inout Workout) {
        workout.tagsCache = Self.buildTagsCache(from: "\(workout.title)\n\(workout.content)")
    }
    
    static func updateTagsCache(for workouts: inout [Workout]) {
        for index in workouts.indices {
            updateTagsCache(for: &workouts[index])
        }
    }
        
    static private func buildTagsCache(from text: String) -> Set<Int> {
        let normalizedText = Self.normalize(text)
                
        return Set(
            allNormalizedTags.enumerated()
                .filter { _, tag in
                    normalizedText.contains(tag)
                }
                .map(\.0)
        )
    }
}
