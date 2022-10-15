//
//  MessageView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import SwiftUI

struct MessageView: View {
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
        .if(message.isUnread) { view in
            view.overlay(Rectangle().frame(maxWidth: .infinity, maxHeight: 5).foregroundColor(Color.mint), alignment: .top)
        }
        .cornerRadius(10)
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        let message = Message.sample

        MessageView(message: message)
    }
}
