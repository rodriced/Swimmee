//
//  SwimmerMessagesView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 09/10/2022.
//

import SwiftUI

class SwimmerMessagesViewModel {
    struct Config: ViewModelConfig {
        let profileAPI: ProfileSwimmerAPI

        static var `default` = Config(profileAPI: API.shared.profile)
    }

    let config: Config

    typealias LoadedData = ([Message], Set<Message.DbId>)
    typealias MessagesParams = [(message: Message, isRead: Bool)]

    @Published var messagesParams: [(message: Message, isRead: Bool)]
    @Published var newMessagesCount: Int

    required init(initialData: LoadedData, config: Config = .default) {
        print("SwimmerMessagesViewModel.init")
        (messagesParams, newMessagesCount) = Self.formatLoadedData(initialData)
        self.config = config
    }

    static func formatLoadedData(_ loadedData: LoadedData) -> (MessagesParams, Int) {
        let (messages, readMessagesIds) = loadedData

        let messagesParams =
            messages.map { message in
                (message: message,
                 isRead: message.dbId.map { readMessagesIds.contains($0) } ?? false)
            }
        let newMessagesCount = messagesParams.filter { !$0.isRead }.count

        return (messagesParams, newMessagesCount)
    }

    var restartLoader: (() -> Void)?

    func setMessageAsRead(_ message: Message) {
        guard let dbId = message.dbId else { return }
        Task {
            try? await config.profileAPI.setMessageAsRead(dbId)
        }
    }
}

extension SwimmerMessagesViewModel: LoadableViewModel {
    func refreshedLoadedData(_ loadedData: LoadedData) {
        (messagesParams, newMessagesCount) = Self.formatLoadedData(loadedData)
    }
}

struct SwimmerMessagesView: View {
    typealias ViewModel = SwimmerMessagesViewModel

    @EnvironmentObject var session: SwimmerSession
    @ObservedObject var vm: SwimmerMessagesViewModel

    init(_ vm: SwimmerMessagesViewModel) {
        print("SwimmerMessagesView.init")
        _vm = ObservedObject(initialValue: vm)
    }

    var newMessagesCountInfo: String {
        let plural = vm.newMessagesCount > 1 ? "s" : ""
        return "You have \(vm.newMessagesCount) new message\(plural)"
    }

    var messagesList: some View {
        List(vm.messagesParams, id: \.0.id) { message, isRead in
            MessageView(message: message, inReception: true, isRead: isRead)
                .listRowSeparator(.hidden)
                .onTapGesture {
                    vm.setMessageAsRead(message)
                }
        }
        .refreshable { vm.restartLoader?() }
        .listStyle(.plain)
    }

    var body: some View {
        VStack(spacing: 30) {
            if vm.messagesParams.isEmpty {
                Text(
                    session.coachId == nil ?
                        "Subscribe to a coach in the Settings menu\nto see his messages."
                        : "No messages from your coach for now."
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
