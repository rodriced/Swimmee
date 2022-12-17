//
//  EditMessageView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import SwiftUI

@MainActor
class EditMessageViewModel: ObservableObject {
//    @Published var message: Message = .empty
    let messageAPI: UserMessageCollectionAPI
    let originalMessage: Message
    @Published var message: Message

    func validateTitle() -> Bool {
        !message.title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var canSend: Bool {
        !message.isSent || (message.isSent && message.hasTextDifferent(from: originalMessage))
    }

    var canSaveAsDraft: Bool {
        message.isSent || (!message.isSent && message.hasTextDifferent(from: originalMessage))
    }

    @Published var alertContext = AlertContext()

    init(message: Message, messageAPI: UserMessageCollectionAPI = API.shared.message) {
//        print("EditMessageViewModel.init (message)")
        self.originalMessage = message
        self.message = message
        self.messageAPI = messageAPI
    }

    func saveMessage(andSendIt: Bool, completion: (() -> Void)?) {
        var messageToSave = message // Working on a copy prevent reactive behaviours of the original message on UI
        messageToSave.isSent = andSendIt

        Task {
            var replaceAsNew = false

            switch (message.isSent, andSendIt) {
            case (_, true):
                replaceAsNew = true
                messageToSave.date = .now
            // TODO: A draft message sent for the first time should not be send as new message because it has never been read by anyone (we track read message with dbId and there is no reason here to generate a new one to set as unread for all swimmers)
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

struct EditMessageView: View {
    @StateObject var vm: EditMessageViewModel
    @Environment(\.presentationMode) private var presentationMode

    @State var deleteConfirmationPresented = false
    @State var unsendAndSaveAsDraftConfirmationPresented = false
    @State var resendConfirmationPresented = false
    @State var saveAsDraftConfirmationPresented = false
    @State var sendConfirmationPresented = false

    @FocusState private var isTitleFocused: Bool

    init(message: Message) {
//        print("EditMessageView.init (titile = \(message.title)")
        _vm = StateObject(wrappedValue: EditMessageViewModel(message: message))
    }

    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }

    var bottomButtonsBar: some View {
        func doIfFormValidated(action: () -> Void) {
            guard vm.validateTitle() else {
                vm.alertContext.message = "Put something in title and retry."
                isTitleFocused = true
                return
            }

            action()
        }

        let config = vm.message.isSent ?
            (saveAsDraft: (
                buttonLabel: "Unsend and save as draft",
                confirmationTitle: "Unsend and save as draft ?",
                confirmationPresented: $unsendAndSaveAsDraftConfirmationPresented,
                confirmationButton: { Button("Confirm Save as draft") {
                    vm.saveMessage(andSendIt: false, completion: dismiss)
                }}
            ),
            sendButton: (
                buttonLabel: "Replace (Re-send)",
                confirmationTitle: "Replace sent message ?",
                confirmationPresented: $resendConfirmationPresented,
                confirmationButton: { Button("Confirm Replace") {
                    vm.saveMessage(andSendIt: true, completion: dismiss)
                }}
            ))
            :
            (saveAsDraft: (
                buttonLabel: "Save as draft",
                confirmationTitle: "Save as draft ?",
                confirmationPresented: $saveAsDraftConfirmationPresented,
                confirmationButton: { Button("Confirm Save as draft") {
                    vm.saveMessage(andSendIt: false, completion: dismiss)
                }}
            ),
            sendButton: (
                buttonLabel: "Send",
                confirmationTitle: "Send message ?",
                confirmationPresented: $sendConfirmationPresented,
                confirmationButton: { Button("Confirm Send") {
                    vm.saveMessage(andSendIt: true, completion: dismiss)
                }}
            ))

        return HStack {
            Button {
                config.saveAsDraft.confirmationPresented.wrappedValue = true
            } label: {
                Text(config.saveAsDraft.buttonLabel)
                    .frame(maxWidth: .infinity)
            }
            .foregroundColor(Color.black)
            .tint(Color.orange.opacity(0.7))
            .disabled(!vm.canSaveAsDraft)
            .confirmationDialog(config.saveAsDraft.confirmationTitle, isPresented: config.saveAsDraft.confirmationPresented, actions: config.saveAsDraft.confirmationButton)

            Button {
                config.sendButton.confirmationPresented.wrappedValue = true
            } label: {
                Text(config.sendButton.buttonLabel)
                    .frame(maxWidth: .infinity)
            }
            .disabled(!vm.canSend)
            .confirmationDialog(config.sendButton.confirmationTitle, isPresented: config.sendButton.confirmationPresented, actions: config.sendButton.confirmationButton)
        }
        .buttonStyle(.borderedProminent)
    }

    var body: some View {
        VStack {
//            DebugHelper.viewBodyPrint("EditMessageView")
            if vm.message.isSent {
                Label("Message is published", systemImage: "exclamationmark.triangle")
                    .foregroundColor(.mint)
            }

            Form {
                Section {
                    TextField("Title", text: $vm.message.title)
                        .focused($isTitleFocused)
                }
                TextEditorWithPlaceholder(text: $vm.message.content, placeholder: "Content", height: 400)
            }

            bottomButtonsBar
                .padding()
        }
        .navigationBarTitle(vm.originalMessage.isNew ? "Create message" : "Edit message", displayMode: .inline)
        .navigationBarBackButtonHidden()

        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    deleteConfirmationPresented = true
                } label: {
                    Image(systemName: "trash").foregroundColor(Color.red)
                }
                .confirmationDialog("Delete message ?", isPresented: $deleteConfirmationPresented) {
                    Button("Delete message ?") { vm.deleteMessage(completion: dismiss) }
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }

        .alert(vm.alertContext) {}
    }
}

struct EditMessageView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditMessageView(message: Message.sample)
        }
    }
}
