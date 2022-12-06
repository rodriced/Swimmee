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
    
    var canSend : Bool {
        !message.isSent || (message.isSent && message.hasTextDifferent(from: originalMessage))
    }

    var canSaveAsDraft : Bool {
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
//    @StateObject var vm = EditMessageViewModel()
    @StateObject var vm: EditMessageViewModel
    @Environment(\.presentationMode) private var presentationMode

    @State var confirmationDialogPresented: ConfirmationDialog?

//    let message: Message

    init(message: Message) {
//        print("EditMessageView.init (titile = \(message.title)")
//        self.message = message
        _vm = StateObject(wrappedValue: EditMessageViewModel(message: message))
    }

    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }

    var sendConfirmationDialog: ConfirmationDialog {
        ConfirmationDialog(
            title: "Send message ?",
            primaryButton: "send",
            primaryAction: { vm.saveMessage(andSendIt: true, completion: dismiss) }
        )
    }

    var resendConfirmationDialog: ConfirmationDialog {
        ConfirmationDialog(
            title: "Replace sent message ?",
            primaryButton: "Replace",
            primaryAction: { vm.saveMessage(andSendIt: true, completion: dismiss) }
        )
    }

    var unsendAndSaveAsDraftConfirmationDialog: ConfirmationDialog {
        ConfirmationDialog(
            title: "Unsend and save as draft ?",
            primaryButton: "Save as draft",
            primaryAction: { vm.saveMessage(andSendIt: false, completion: dismiss) }
        )
    }

    var deleteConfirmationDialog: ConfirmationDialog {
        ConfirmationDialog(
            title: "Delete message ?",
            primaryButton: "Delete",
            primaryAction: { vm.deleteMessage(completion: dismiss) }
        )
    }

    var bottomButtonsBar: some View {
        let config = vm.message.isSent ?
            (saveAsDraftButton: (
                label: "Unsend and save as draft",
                action: { confirmationDialogPresented = unsendAndSaveAsDraftConfirmationDialog }
            ),
            sendButton: (
                label: "Replace (Re-send)",
                action: { confirmationDialogPresented = resendConfirmationDialog }
            ))
            :
            (saveAsDraftButton: (
                label: "Save as draft",
                action: { vm.saveMessage(andSendIt: false, completion: dismiss) }
            ),
            sendButton: (
                label: "Send",
                action: { confirmationDialogPresented = sendConfirmationDialog }
            ))

        return HStack {
            Button(action: config.saveAsDraftButton.action) {
                Text(config.saveAsDraftButton.label)
                    .frame(maxWidth: .infinity)
            }
            .foregroundColor(Color.black)
            .tint(Color.orange.opacity(0.7))
            .disabled(!vm.canSaveAsDraft)

            Button(action: config.sendButton.action) {
                Text(config.sendButton.label)
                    .frame(maxWidth: .infinity)
            }
            .disabled(!vm.canSend)
//            .keyboardShortcut(.defaultAction)
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
                }
                TextEditorWithPlaceholder(text: $vm.message.content, placeholder: "Content", height: 400)
            }

            bottomButtonsBar
                .padding()
        }
//        .onAppear { vm.message = message }

        .actionSheet(item: $confirmationDialogPresented) { dialog in
            dialog.actionSheet()
        }

        .navigationTitle("Edit message")
        .navigationBarBackButtonHidden()

        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    confirmationDialogPresented = deleteConfirmationDialog
                } label: {
                    Image(systemName: "trash").foregroundColor(Color.red)
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
