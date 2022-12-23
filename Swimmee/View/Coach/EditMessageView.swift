//
//  EditMessageView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import SwiftUI

struct EditMessageView: View {
    @Environment(\.presentationMode) private var presentationMode
    private func dismiss() { presentationMode.wrappedValue.dismiss() }

    @StateObject var viewModel: EditMessageViewModel

    @State var deleteConfirmationPresented = false
    @FocusState private var isTitleFocused: Bool

    init(message: Message) {
//        print("EditMessageView.init (titile = \(message.title)")
        _viewModel = StateObject(wrappedValue: EditMessageViewModel(message: message))
    }
    
    // MARK: - Components

    // MARK: Delete button
    
    var deleteButton: some View {
        Button {
            deleteConfirmationPresented = true
        } label: {
            Image(systemName: "trash").foregroundColor(Color.red)
        }
        .confirmationDialog("Delete message ?", isPresented: $deleteConfirmationPresented) {
            Button("Delete message ?") { viewModel.deleteMessage(completion: dismiss) }
        }
    }

    // MARK: Bottom buttons

    struct SaveAsDraftButtonModifier: ViewModifier {
        func body(content: Content) -> some View {
            content.foregroundColor(Color.black)
                .tint(Color.orange.opacity(0.7))
        }
    }

    var unsentAndSaveAsDraftButton: some View {
        ButtonWithConfirmation(label: "Unsend and save as draft",
                     isDisabled: !viewModel.canTryToSaveAsDraft,
                     confirmationTitle: "Unsend and save as draft ?",
                     confirmationButtonLabel: "Confirm Save as draft",
                     buttonModifier: SaveAsDraftButtonModifier(),
                     action: {
                         viewModel.saveMessage(andSendIt: false, onValidationError: { isTitleFocused = true })
                     })
    }

    var resendButton: some View {
        ButtonWithConfirmation(label: "Replace (Re-send)",
                     isDisabled: !viewModel.canTryToSend,
                     confirmationTitle: "Replace already sent message ?",
                     confirmationButtonLabel: "Confirm Replace ?",
                     action: {
                         viewModel.saveMessage(andSendIt: true, onValidationError: { isTitleFocused = true })
                     })
    }

    var saveAsDraftButton: some View {
        ButtonWithConfirmation(label: "Save as draft",
                     isDisabled: !viewModel.canTryToSaveAsDraft,
                     confirmationTitle: "Save as draft ?",
                     confirmationButtonLabel: "Confirm Save as draft",
                     buttonModifier: SaveAsDraftButtonModifier(),
                     action: {
                         viewModel.saveMessage(andSendIt: false, onValidationError: { isTitleFocused = true })
                     })
    }

    var sendButton: some View {
        ButtonWithConfirmation(label: "Send",
                     isDisabled: !viewModel.canTryToSend,
                     confirmationTitle: "Send ?",
                     confirmationButtonLabel: "Send message ?",
                     action: {
                         viewModel.saveMessage(andSendIt: true, onValidationError: { isTitleFocused = true })
                     })
    }

    var bottomButtonsBar: some View {
        HStack {
            if viewModel.message.isSent {
                unsentAndSaveAsDraftButton
                resendButton
            } else {
                saveAsDraftButton
                sendButton
            }
        }
    }
    
    // MARK: - Layout organization

    var body: some View {
        VStack {
//            DebugHelper.viewBodyPrint("EditMessageView")
            if viewModel.message.isSent {
                Label("Message is sent", systemImage: "exclamationmark.triangle")
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
        .onTapGesture {
            hideKeyboard()
        }
        .navigationBarTitle(viewModel.originalMessage.isNew ? "Create message" : "Edit message", displayMode: .inline)
        .navigationBarBackButtonHidden()

        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if !viewModel.originalMessage.isNew {
                    deleteButton
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: dismiss)
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
