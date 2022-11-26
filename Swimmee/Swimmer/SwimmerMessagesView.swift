//
//  SwimmerMessagesView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 09/10/2022.
//

import SwiftUI

class SwimmerMessagesViewModel {
    @Published var messagesConfigs: [(message: Message, isRead: Bool)] = []
    @Published var newMessagesCount: Int = 0

    required init() {
        print("SwimmerMessagesViewModel.init")
    }

    var reload: (() -> Void)?

    func setMessageAsRead(_ message: Message) {
        guard let dbId = message.dbId else { return }
        Task {
            try? await API.shared.profile.setMessageAsRead(dbId)
        }
    }
}

extension SwimmerMessagesViewModel: LoadableViewModel {
    func injectLoadedData(_ loadedData: ([Message], Set<Message.DbId>)) {
        let (messages, readMessagesIds) = loadedData

        messagesConfigs =
            messages.map { message in
                (message: message,
                 isRead: message.dbId.map { readMessagesIds.contains($0) } ?? false)
            }
        newMessagesCount = messagesConfigs.filter { !$0.isRead }.count
    }
}

struct SwimmerMessagesView: View {
    typealias ViewModel = SwimmerMessagesViewModel

    @EnvironmentObject var session: UserSession
    @ObservedObject var vm: SwimmerMessagesViewModel

    init(_ vm: SwimmerMessagesViewModel) {
        print("SwimmerhMessagesViewModel.init")
        _vm = ObservedObject(wrappedValue: vm)
    }

    var newMessagesCountInfo: String {
        let plural = vm.newMessagesCount > 1 ? "s" : ""
        return "You have \(vm.newMessagesCount) new message\(plural)"
    }

    var messagesList: some View {
        List(vm.messagesConfigs, id: \.0.id) { message, isRead in
            MessageView(message: message, inReception: session.isSwimmer, isRead: isRead)
                .listRowSeparator(.hidden)
                .onTapGesture {
                    vm.setMessageAsRead(message)
                }
        }
        .refreshable { vm.reload?() }
        .listStyle(.plain)
    }

    var body: some View {
        VStack(spacing: 30) {
            if vm.messagesConfigs.isEmpty {
                Text(
                    session.coachId == nil ?
                        "No messages.\nSubscribe to a coach in the Settings menu."
                        : "No messages from your coach."
                )
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                
            } else {
                if vm.newMessagesCount > 0 {
                    Text(newMessagesCountInfo)
                }
                messagesList
            }
        }
        .navigationBarTitle("Messages", displayMode: .inline)
    }
}

// struct SwimmerMessagesView_Previews: PreviewProvider {
//    static var previews: some View {
//        SwimmerMessagesView()
//    }
// }
