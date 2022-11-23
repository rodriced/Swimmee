//
//  MessageView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import SwiftUI

struct MessageView: View {
    let message: Message
    let isRead: Bool

    let typeColor: Color
    let typeText: String

    init(message: Message, inReception: Bool, isRead: Bool = false) {
        self.message = message
        self.isRead = isRead

        (typeColor, typeText) = {
            if inReception {
                return isRead ?
                    (Color.white, "") : (Color.mint, "")
            } else {
                return message.isSended ?
                    (Color.mint, "sent") : (Color.orange, "draft")
            }
        }()
    }

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline) {
                    Text(message.date, style: .date).font(.caption)
                    Text(message.date, style: .time).font(.caption)
                    Spacer()
                    Text(typeText)
                        .font(.headline)
                        .foregroundColor(typeColor)
                }
                Text(message.title).font(.headline)
                Text(message.content).font(.body)
            }
        } icon: {
            Image(systemName: "message")
                .font(Font.headline)
                .foregroundColor(Color.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .topBorder(color: typeColor)
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

        Group {
            MessageView(message: notSendedMessage, inReception: false)
            MessageView(message: sendedMessage, inReception: false)
            MessageView(message: sendedMessage, inReception: true, isRead: false)
            MessageView(message: sendedMessage, inReception: true, isRead: true)
        }
    }
}
