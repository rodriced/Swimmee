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
//        print("SwimmerMessagesViewModel.init")
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
    @EnvironmentObject var session: SwimmerSession
    @EnvironmentObject var router: UserRouter

    @ObservedObject var viewModel: SwimmerMessagesViewModel

    init(_ viewModel: SwimmerMessagesViewModel) {
//        print("SwimmerMessagesView.init")
        _viewModel = ObservedObject(initialValue: viewModel)
    }

    var newMessagesCountInfo: String {
        let plural = viewModel.newMessagesCount > 1 ? "s" : ""
        return "You have \(viewModel.newMessagesCount) new message\(plural)"
    }

    var messagesList: some View {
        List(viewModel.messagesParams, id: \.0.id) { message, isRead in
            MessageView(message: message, inReception: true, isRead: isRead)
                .listRowSeparator(.hidden)
                .onTapGesture {
                    viewModel.setMessageAsRead(message)
                }
        }
        .refreshable { viewModel.restartLoader?() }
        .listStyle(.plain)
    }

    var body: some View {
        VStack(spacing: 30) {
            if viewModel.messagesParams.isEmpty {
                if session.coachId == nil {
                    VStack {
                        Text("Your coach will publish some messages here.\nBut you haven't selcted one.\n")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        Button {
                            router.routeTo(setting: .coachSelection)
                        } label: {
                            Text("You can do it in settings ")
                            + Text(Image(systemName: "arrow.forward"))
                        }
                    }
                } else {
                    Text("No messages from your coach for now.")
                        .foregroundColor(.secondary)
                }

            } else {
                if viewModel.newMessagesCount > 0 {
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
