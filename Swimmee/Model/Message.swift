//
//  Message.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import Foundation

struct Message: Identifiable {
    let id = UUID()
    let date: Date = .now
    var title: String
    var content: String
    var isUnread: Bool
    
    static var sample = Message(title: "Message", content: "Bla bla bla\nBlalbla blaaaaaa", isUnread: true)
    
    func toSamples(_ nbElements: Int) -> [Message] {
        (1 ... nbElements).map {
            Message(title: title + String($0), content: content, isUnread: isUnread)
        }
    }
}
