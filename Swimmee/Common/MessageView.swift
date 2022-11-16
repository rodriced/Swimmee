//
//  MessageView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import SwiftUI

struct MessageView: View {
    @EnvironmentObject var session: UserSession
    let message: Message
    let isRead: Bool
    
    init(message: Message, isRead: Bool = false) {
        self.message = message
        self.isRead = isRead
    }
    
    var indicatorColor: Color {
        session.isCoach ?
            (message.isSended ? Color.mint : Color.orange)
            :
        (isRead ? Color.white : Color.mint)
    }

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 10) {
                Text(message.date, style: .date).font(.caption)
                Text(message.title).font(.headline)
                Text(message.content).font(.body)
            }
        } icon: {
            Image(systemName: "message")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .topBorder(color: indicatorColor)
        .cornerRadius(10)
    }
}

//struct MessageView_Previews: PreviewProvider {
//    static var previews: some View {
//        let notSendedMessage = Message.sample
//        let sendedMessage: Message = {
//            var msg = Message.sample
//            msg.isSended = true
//            return msg
//        }()
//        let readMessage: Message = {
//            var msg = sendedMessage
//            msg.isUnread = false
//            return msg
//        }()
//
//        Group {
//            MessageView(message: notSendedMessage)
//                .environmentObject(UserSession(userId: "", userType: .coach))
//            MessageView(message: sendedMessage)
//                .environmentObject(UserSession(userId: "", userType: .coach))
//            MessageView(message: readMessage)
//                .environmentObject(UserSession(userId: "", userType: .swimmer))
//            MessageView(message: sendedMessage)
//                .environmentObject(UserSession(userId: "", userType: .swimmer))
//        }
//    }
//}
