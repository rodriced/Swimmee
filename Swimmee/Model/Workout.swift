//
//  Message.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import Foundation

struct Workout: Identifiable {
    let id = UUID()
    let date: Date
    let duration: Int
    let title: String
    let content: String
    let isDraft: Bool
    
//    init(date: Date, duration: (hour: Int, minute: Int), title: String, content: String, isDraft: Bool) {
//        self.date = date
//        self.duration = DateComponents(hour: duration.hour, minute: duration.minute).date!
//        self.title = title
//        self.content = content
//        self.isDraft = isDraft
//    }
}
