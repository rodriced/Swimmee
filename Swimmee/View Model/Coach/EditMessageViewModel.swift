//
//  EditMessageViewModel.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import Combine

class EditMessageViewModel: ObservableObject {
    let messageAPI: UserMessageCollectionAPI
    let originalMessage: Message
    @Published var message: Message

    func validateTitle() -> Bool {
        !message.title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var canTryToSend: Bool {
        !message.isSent || (message.isSent && message.hasTextDifferent(from: originalMessage))
    }

    var canTryToSaveAsDraft: Bool {
        message.isSent || (!message.isSent && message.hasTextDifferent(from: originalMessage))
    }

    @Published var alertContext = AlertContext()

    init(message: Message, messageAPI: UserMessageCollectionAPI = API.shared.message) {
//        print("EditMessageViewModel.init (message)")
        self.originalMessage = message
        self.message = message
        self.messageAPI = messageAPI
    }

    func saveMessage(andSendIt: Bool, completion: (() -> Void)? = nil) {
        Task {
            var messageToSave = message
            messageToSave.isSent = andSendIt

            var replaceAsNew = false

            switch (message.isSent, andSendIt) {
            case (_, true):
                replaceAsNew = true
                messageToSave.date = .now
//            case (false, true):
//                messageToSave.date = .now
            case (_, false):
                ()
            }

            do {
                _ = try await messageAPI.save(messageToSave, replaceAsNew: replaceAsNew)
                completion?()
            } catch {
                alertContext.message = error.localizedDescription
            }
        }
    }

    func deleteMessage(completion: (() -> Void)?) {
        guard let dbId = message.dbId else {
            completion?()
            return
        }

        Task {
            do {
                try await messageAPI.delete(id: dbId)
                completion?()
            } catch {
                alertContext.message = error.localizedDescription
            }
        }
    }
}
