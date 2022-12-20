//
//  EditMessageView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import SwiftUI

struct EditMessageView: View {
    @Environment(\.presentationMode) private var presentationMode

    @StateObject var viewModel: EditMessageViewModel

    @State var deleteConfirmationPresented = false
    @State var unsendAndSaveAsDraftConfirmationPresented = false
    @State var resendConfirmationPresented = false
    @State var saveAsDraftConfirmationPresented = false
    @State var sendConfirmationPresented = false

    @FocusState private var isTitleFocused: Bool

    init(message: Message) {
//        print("EditMessageView.init (titile = \(message.title)")
        _viewModel = StateObject(wrappedValue: EditMessageViewModel(message: message))
    }

    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }

    var bottomButtonsBar: some View {
        func doIfFormValidated(action: () -> Void) {
            guard viewModel.validateTitle() else {
                viewModel.alertContext.message = "Put something in title and retry."
                isTitleFocused = true
                return
            }

            action()
        }

        let config = viewModel.message.isSent ?
            (saveAsDraft: (
                buttonLabel: "Unsend and save as draft",
                confirmationTitle: "Unsend and save as draft ?",
                confirmationPresented: $unsendAndSaveAsDraftConfirmationPresented,
                confirmationButton: { Button("Confirm Save as draft") {
                    viewModel.saveMessage(andSendIt: false, completion: dismiss)
                }}
            ),
            sendButton: (
                buttonLabel: "Replace (Re-send)",
                confirmationTitle: "Replace sent message ?",
                confirmationPresented: $resendConfirmationPresented,
                confirmationButton: { Button("Confirm Replace") {
                    viewModel.saveMessage(andSendIt: true, completion: dismiss)
                }}
            ))
            :
            (saveAsDraft: (
                buttonLabel: "Save as draft",
                confirmationTitle: "Save as draft ?",
                confirmationPresented: $saveAsDraftConfirmationPresented,
                confirmationButton: { Button("Confirm Save as draft") {
                    viewModel.saveMessage(andSendIt: false, completion: dismiss)
                }}
            ),
            sendButton: (
                buttonLabel: "Send",
                confirmationTitle: "Send message ?",
                confirmationPresented: $sendConfirmationPresented,
                confirmationButton: { Button("Confirm Send") {
                    viewModel.saveMessage(andSendIt: true, completion: dismiss)
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
            .disabled(!viewModel.canTryToSaveAsDraft)
            .confirmationDialog(config.saveAsDraft.confirmationTitle, isPresented: config.saveAsDraft.confirmationPresented, actions: config.saveAsDraft.confirmationButton)

            Button {
                config.sendButton.confirmationPresented.wrappedValue = true
            } label: {
                Text(config.sendButton.buttonLabel)
                    .frame(maxWidth: .infinity)
            }
            .disabled(!viewModel.canTryToSend)
            .confirmationDialog(config.sendButton.confirmationTitle, isPresented: config.sendButton.confirmationPresented, actions: config.sendButton.confirmationButton)
        }
        .buttonStyle(.borderedProminent)
    }

    var body: some View {
        VStack {
//            DebugHelper.viewBodyPrint("EditMessageView")
            if viewModel.message.isSent {
                Label("Message is published", systemImage: "exclamationmark.triangle")
                    .foregroundColor(.mint)
            }

            Form {
                Section {
                    TextField("Title", text: $viewModel.message.title)
                        .focused($isTitleFocused)
                }
                TextEditorWithPlaceholder(text: $viewModel.message.content, placeholder: "Content", height: 400)
            }

            bottomButtonsBar
                .padding()
        }
        .navigationBarTitle(viewModel.originalMessage.isNew ? "Create message" : "Edit message", displayMode: .inline)
        .navigationBarBackButtonHidden()

        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    deleteConfirmationPresented = true
                } label: {
                    Image(systemName: "trash").foregroundColor(Color.red)
                }
                .confirmationDialog("Delete message ?", isPresented: $deleteConfirmationPresented) {
                    Button("Delete message ?") { viewModel.deleteMessage(completion: dismiss) }
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }

        .alert(viewModel.alertContext) {}
    }
}

struct EditMessageView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditMessageView(message: Message.sample)
        }
    }
}
