//
//  WorkoutTags.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 26/12/2022.
//

// MARK: Workout tags management

extension Workout {
    static let allTags = ["backstroke", "breaststroke", "butterfly", "dolphin kick", "flutter kick", "freestyle", "frog kick", "medley", "relay"]
    
    private static func normalize(_ tag: String) -> String {
        tag.filter { !$0.isWhitespace }.lowercased()
    }
    
    private static var allNormalizedTags = allTags.map(normalize)
    
    static func updateTagsCache(for workout: inout Workout) {
        workout.tagsCache = Self.buildTagsCache(from: "\(workout.title)\n\(workout.content)")
    }
    
    static func updateTagsCache(for workouts: inout [Workout]) {
        for index in workouts.indices {
            updateTagsCache(for: &workouts[index])
        }
    }
        
    private static func buildTagsCache(from text: String) -> Set<Int> {
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
