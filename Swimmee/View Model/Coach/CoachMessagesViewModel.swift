//
//  CoachMessagesViewModel.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 09/10/2022.
//

import Foundation
import Combine

enum CoachMessagesFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case draft = "Draft only"
    case sent = "Sent only"

    var id: Self { self }
}

class CoachMessagesViewModel: LoadableViewModel {

    // MARK: - Config

    struct Config: ViewModelConfig {
        let messageAPI: UserMessageCollectionAPI
        
        static let `default` = Config(messageAPI: API.shared.message)
    }
    
    let config: Config

    //
    // MARK: - Properties
    //
    
    @Published var messages: [Message]

    @Published var filter = CoachMessagesFilter.all

    var filteredMessages: [Message] {
        messages.filter { message in
            filter == .all
                || (filter == .draft && !message.isSent)
                || (filter == .sent && message.isSent)
        }
    }

    @Published var selectedMessage: Message?
    @Published var sentMessageEditionConfirmationDialogPresented = false
    @Published var navigatingToEditView = false

    @Published var alertContext = AlertContext()

    //
    // MARK: - Protocol LoadableViewModel implementation
    //
    
    required init(initialData: [Message], config: Config = .default) {
        messages = initialData
        self.config = config
    }
    
    func refreshedLoadedData(_ loadedData: [Message]) {
        messages = loadedData
    }

    var restartLoader: (() -> Void)?

    //
    // MARK: - Actions
    //
    
    func goEditingMessage(_ message: Message) {
        selectedMessage = message

        if message.isSent {
            sentMessageEditionConfirmationDialogPresented = true
            navigatingToEditView = false

        } else {
            sentMessageEditionConfirmationDialogPresented = false
            navigatingToEditView = true
        }
    }

    func deleteMessage(at offsets: IndexSet) {
        guard let index = offsets.first else { return }

        let messageToDelete = messages[index]

        Task {
            do {
                if let dbId = messageToDelete.dbId {
                    try await config.messageAPI.delete(id: dbId)
                }
                await MainActor.run { messages.remove(atOffsets: offsets) }
            } catch {
                await MainActor.run { alertContext.message = error.localizedDescription }
            }
        }
    }
}
