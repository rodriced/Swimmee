//
//  Samples.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 11/12/2022.
//

@testable import Swimmee

import Foundation

class Samples {
    static var aCoachProfile: Profile {
        Profile(userId: "", userType: .coach, firstName: "aFirstName", lastName: "aLastName", email: "an@e.mail")
    }
    
    static var aSwimmerProfile: Profile {
        Profile(userId: "", userType: .swimmer, firstName: "aFirstName", lastName: "aLastName", email: "an@e.mail")
    }
    
    static var aTeam: [Profile] {
        (1..<5).map {
            Profile(userId: "\($0)", userType: .swimmer, firstName: "aFirstName\($0)", lastName: "aLastName\($0)", email: "an\($0)@e.mail")
        }
    }
    
    static var aCoachsList: [Profile] {
        (10..<15).map {
            Profile(userId: "\($0)", userType: .coach, firstName: "aFirstName\($0)", lastName: "aLastName\($0)", email: "an\($0)@e.mail")
        }
    }
    
    static func aWorkout(userId: UserId, isSent: Bool = false) -> Workout {
        Workout(userId: userId, title: "A Workout Title", content: "A workout content\nwith multiples\nlines.", isSent: isSent)
    }

    static func aWorkoutsList(userId: UserId, areSent: [Bool]? = nil) -> [Workout] {
        let areSent = areSent ?? Array(repeating: false, count: 5)
        
        return areSent.enumerated().map { index, isSent in
            let ref = 200 + index
            return Workout(dbId: UUID().uuidString, userId: userId, title: "A Workout Title \(ref)", content: "A workout content \(ref)\nwith multiples\nlines.", isSent: isSent)
        }
    }

    static func aMessage(userId: UserId, isSent: Bool = false) -> Message {
        Message(userId: userId, title: "A Title", content: "A message content\nwith multiples\nlines.", isSent: isSent)
    }
    
    static func aMessagesList(userId: UserId, areSent: [Bool]? = nil) -> [Message] {
        let areSent = areSent ?? Array(repeating: false, count: 5)
        
        return areSent.enumerated().map { index, isSent in
            let ref = 200 + index
            return Message(dbId: UUID().uuidString, userId: userId, title: "A Title \(ref)", content: "A message content \(ref)\nwith multiples\nlines.", isSent: isSent)
        }
    }
    
}
