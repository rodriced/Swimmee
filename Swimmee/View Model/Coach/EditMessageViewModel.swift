//
//  EditMessageViewModel.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import Combine

class EditMessageViewModel: ObservableObject {
    
    // MARK: - Config
    
    let messageAPI: UserMessageCollectionAPI

    //
    // MARK: - Properties
    //
    
    let originalMessage: Message
    @Published var message: Message

    @Published var alertContext = AlertContext()

    init(message: Message, messageAPI: UserMessageCollectionAPI = API.shared.message) {
//        print("EditMessageViewModel.init (message)")
        self.originalMessage = message
        self.message = message
        self.messageAPI = messageAPI
    }

    //
    // MARK: - Form validation
    //

    func validateTitle() -> Bool {
        !message.title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var canTryToSend: Bool {
        !message.isSent || (message.isSent && message.hasTextDifferent(from: originalMessage))
    }

    var canTryToSaveAsDraft: Bool {
        message.isSent || (!message.isSent && message.hasTextDifferent(from: originalMessage))
    }

    //
    // MARK: - Actions
    //
    
    func saveMessage(andSendIt: Bool, onValidationError: (() -> Void)? = nil) {
        guard validateTitle() else {
            alertContext.message = "Put something in title and retry."
            onValidationError?()
            return
        }
        
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
