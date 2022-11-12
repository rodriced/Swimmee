//
//  MessageView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import SwiftUI

struct TopBorder: ViewModifier {
    let color: Color
    let height: CGFloat

    func body(content: Content) -> some View {
        content
            .overlay(Rectangle()
                .frame(maxWidth: .infinity, maxHeight: height)
                .foregroundColor(Color.mint), alignment: .top)
    }
}

extension View {
    func topBorder(color: Color, height: CGFloat = 5) -> some View {
        modifier(TopBorder(color: color, height: height))
    }
}

struct MessageView: View {
    @EnvironmentObject var session: UserSession
    let message: Message

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
        .if(session.isSwimmer && message.isUnread) {
            $0.topBorder(color: Color.mint)
        }
//        { view in
//            view.overlay(Rectangle().frame(maxWidth: .infinity, maxHeight: 5).foregroundColor(Color.mint), alignment: .top)
//        }
        .if(session.isCoach) {
            $0.topBorder(color: message.isSended ? Color.mint : Color.orange)
        }
//        { view in
//            view.overlay(Rectangle().frame(maxWidth: .infinity, maxHeight: 5).foregroundColor(Color.orange), alignment: .top)
//        }
        .cornerRadius(10)
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        let message = Message.sample
        let sendedMessage: Message = {
            var msg = Message.sample
            msg.isSended = true
            return msg
        }()

        Group {
            MessageView(message: message)
                .environmentObject(UserSession(userId: "", userType: .coach))
            MessageView(message: sendedMessage)
                .environmentObject(UserSession(userId: "", userType: .coach))
            MessageView(message: message)
                .environmentObject(UserSession(userId: "", userType: .swimmer))
        }
    }
}