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
    let icon: String

    init(message: Message, inReception: Bool, isRead: Bool = false) {
        self.message = message
        self.isRead = isRead

        (typeColor, typeText, icon) = {
            if inReception {
                return isRead ?
                    (.clear, "", "message") : (.mint, "", "message.fill")
            } else {
                return message.isSent ?
                    (.mint, "sent", "arrow.up.message.fill") : (.orange, "draft", "message")
            }
        }()
    }

    var headerView: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(message.date, style: .date).font(.caption)
            Text(message.date, style: .time).font(.caption)
            Spacer()
            Text(typeText)
                .font(.headline)
                .foregroundColor(typeColor)
        }
    }

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 10) {
                headerView
                Text(message.title).font(.headline)
                Text(message.content).font(.body)
            }
        } icon: {
            Image(systemName: icon)
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
        let notSentMessage = Message.sample
        let sentMessage: Message = {
            var msg = Message.sample
            msg.isSent = true
            return msg
        }()

        Group {
            MessageView(message: notSentMessage, inReception: false)
            MessageView(message: sentMessage, inReception: false)
            MessageView(message: sentMessage, inReception: true, isRead: false)
            MessageView(message: sentMessage, inReception: true, isRead: true)
        }
    }
}
