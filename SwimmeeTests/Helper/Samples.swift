//
//  Samples.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 11/12/2022.
//

@testable import Swimmee

import Foundation
import UIKit

class Samples {
    static let aCoachUserId = "A_COACH_USER_ID"
    static let aSwimmerUserId = "A_SWIMMER_USER_ID"
    
    static var aCoachProfile: Profile {
        Profile(userId: aCoachUserId, userType: .coach, firstName: "aFirstName", lastName: "aLastName", email: "an@e.mail")
    }
    
    static var aSwimmerProfile: Profile {
        Profile(userId: aSwimmerUserId, userType: .swimmer, firstName: "aFirstName", lastName: "aLastName", email: "an@e.mail")
    }
    
    static func aProfile(of userType: UserType) -> Profile {
        switch userType {
        case .coach:
            return aCoachProfile
        case .swimmer:
            return aSwimmerProfile
        }
    }
    
    static var aTeam: [Profile] {
        (1..<5).map {
            Profile(userId: "\(aSwimmerUserId)_\($0)", userType: .swimmer, firstName: "aFirstName\($0)", lastName: "aLastName\($0)", email: "an\($0)@e.mail")
        }
    }
    
    static var aCoachsList: [Profile] {
        (10..<15).map {
            Profile(userId: "\(aCoachUserId)_\($0)", userType: .coach, firstName: "aFirstName\($0)", lastName: "aLastName\($0)", email: "an\($0)@e.mail")
        }
    }
    
    static func aWorkout(userId: UserId, isSent: Bool = false) -> Workout {
        Workout(dbId: UUID().uuidString, userId: userId, title: "A Workout Title", content: "A workout content\nwith multiples\nlines.", isSent: isSent)
    }

    static func aWorkoutsList(userId: UserId, areSent: [Bool]? = nil) -> [Workout] {
        let areSent = areSent ?? Array(repeating: false, count: 5)
        
        return areSent.enumerated().map { index, isSent in
            let ref = 200 + index
            return Workout(dbId: UUID().uuidString, userId: userId, title: "A Workout Title \(ref)", content: "A workout content \(ref)\nwith multiples\nlines.", isSent: isSent)
        }
    }

    static func aMessage(userId: UserId, isSent: Bool = false) -> Message {
        Message(dbId: UUID().uuidString, userId: userId, title: "A Title", content: "A message content\nwith multiples\nlines.", isSent: isSent)
    }
    
    static func aMessagesList(userId: UserId, areSent: [Bool]? = nil) -> [Message] {
        let areSent = areSent ?? Array(repeating: false, count: 5)
        
        return areSent.enumerated().map { index, isSent in
            let ref = 200 + index
            return Message(dbId: UUID().uuidString, userId: userId, title: "A Title \(ref)", content: "A message content \(ref)\nwith multiples\nlines.", isSent: isSent)
        }
    }
    
    static let anUrl = URL(string: "https://an.url")!
    
    static var anUIImage: UIImage { anUIImage(size: 10) }
    
    static func anUIImage(size: CGFloat) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))

        let image = renderer.image { context in
            UIColor.darkGray.setStroke()
            context.stroke(renderer.format.bounds)
            UIColor.blue.setFill()
            context.fill(CGRect(x: 1, y: 1, width: size/2, height: size/2))
        }
        return image
    }
    
    static var aPngImage: Data {
        try! ImageHelper.resizedImageData(from: anUIImage)
    }
    
    static var aPhotoInfo: PhotoInfo {
        PhotoInfo(url: anUrl, data: aPngImage)
    }
}
