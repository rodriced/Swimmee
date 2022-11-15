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
    var indicatorColor: Color {
        session.isCoach ?
            (message.isSended ? Color.mint : Color.orange)
            :
            (message.isUnread ? Color.mint : Color.white)
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
//        .if(session.isSwimmer && message.isUnread) {
//            $0.topBorder(color: Color.mint)
//        }
//        { view in
//            view.overlay(Rectangle().frame(maxWidth: .infinity, maxHeight: 5).foregroundColor(Color.mint), alignment: .top)
//        }
//        .if(session.isCoach) {
//            $0.topBorder(color: message.isSended ? Color.mint : Color.orange)
//        }
//        { view in
//            view.overlay(Rectangle().frame(maxWidth: .infinity, maxHeight: 5).foregroundColor(Color.orange), alignment: .top)
//        }
        .cornerRadius(10)
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        let notSendedMessage = Message.sample
        let sendedMessage: Message = {
            var msg = Message.sample
            msg.isSended = true
            return msg
        }()
        let readMessage: Message = {
            var msg = sendedMessage
            msg.isUnread = false
            return msg
        }()

        Group {
            MessageView(message: notSendedMessage)
                .environmentObject(UserSession(userId: "", userType: .coach))
            MessageView(message: sendedMessage)
                .environmentObject(UserSession(userId: "", userType: .coach))
            MessageView(message: readMessage)
                .environmentObject(UserSession(userId: "", userType: .swimmer))
            MessageView(message: sendedMessage)
                .environmentObject(UserSession(userId: "", userType: .swimmer))
        }
    }
}
