//
//  SwimmerMessagesViewModel.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 09/10/2022.
//

import Combine

class SwimmerMessagesViewModel: LoadableViewModel {
    
    // MARK: - Config

    struct Config: ViewModelConfig {
        let profileAPI: ProfileSwimmerAPI

        static var `default` = Config(profileAPI: API.shared.profile)
    }

    let config: Config

    typealias LoadedData = ([Message], Set<Message.DbId>)
    typealias MessagesParams = [(message: Message, isRead: Bool)]

    @Published var messagesParams: MessagesParams
    @Published var newMessagesCount: Int

    //
    // MARK: - Protocol LoadableViewModel implementation
    //

    required init(initialData: LoadedData, config: Config = .default) {
        (messagesParams, newMessagesCount) = Self.formatLoadedData(initialData)
        self.config = config
    }

    func refreshedLoadedData(_ loadedData: LoadedData) {
        (messagesParams, newMessagesCount) = Self.formatLoadedData(loadedData)
    }

    var restartLoader: (() -> Void)?

    private static func formatLoadedData(_ loadedData: LoadedData) -> (MessagesParams, Int) {
        let (messages, readMessagesIds) = loadedData

        let messagesParams =
            messages.map { message in
                (message: message,
                 isRead: message.dbId.map { readMessagesIds.contains($0) } ?? false)
            }
        let newMessagesCount = messagesParams.filter { !$0.isRead }.count

        return (messagesParams, newMessagesCount)
    }

    //
    // MARK: - Actions
    //

    func setMessageAsRead(_ message: Message) {
        guard let dbId = message.dbId else { return }
        Task {
            try? await config.profileAPI.setMessageAsRead(dbId)
        }
    }
}
