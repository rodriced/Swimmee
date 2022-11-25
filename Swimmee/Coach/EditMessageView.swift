//
//  EditMessageView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import SwiftUI

@MainActor
class EditMessageViewModel: ObservableObject {
    @Published var message: Message

    var saveButtonTitle: String {
        message.isSent ? "Unpublish and save as draft" : "Save as draft"
    }

    var senButtonTitle: String {
        message.isSent ? "Re-send" : "Send"
    }

    @Published var errorAlertDisplayed = false {
        didSet { if !errorAlertDisplayed { errorAlertMessage = "" } }
    }

    var errorAlertMessage: String = "" {
        didSet { errorAlertDisplayed = !errorAlertMessage.isEmpty }
    }

    init(message: Message) {
        self.message = message
    }

    init(userId: String) {
        self.message = Message(userId: userId)
    }

    func saveMessage(andSendIt: Bool, completion: (() -> Void)?) {
        Task {
            var saveAsNewMessage = false

            switch (message.isSent, andSendIt) {
                case (true, _):
                    saveAsNewMessage = true
                    message.date = .now
                case (false, true):
                    message.date = .now
                case (false, false):
                    ()
            }

            message.isSent = andSendIt

            do {
                _ = try await API.shared.message.save(message, asNew: saveAsNewMessage)
                completion?()
            } catch {
                errorAlertMessage = error.localizedDescription
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
                try await API.shared.message.delete(id: dbId)
                completion?()
            } catch {
                errorAlertMessage = error.localizedDescription
            }
        }
    }
}

struct EditMessageView: View {
    @ObservedObject var vm: EditMessageViewModel
    @Environment(\.presentationMode) private var presentationMode

    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }

    var body: some View {
        VStack {
            if vm.message.isSent {
                Label("Message is published", systemImage: "exclamationmark.triangle").foregroundColor(.mint)
            }

            Form {
                Section {
                    TextField("Title", text: $vm.message.title)
                }
                TextEditorWithPlaceholder(text: $vm.message.content, placeholder: "Content", height: 400)
            }

            HStack {
                Button {
                    vm.saveMessage(andSendIt: false, completion: dismiss)
                } label: {
                    Text(vm.saveButtonTitle).frame(maxWidth: .infinity)
                }
                .foregroundColor(Color.black)
                .tint(Color.orange.opacity(0.7))

                Button {
                    vm.saveMessage(andSendIt: true, completion: dismiss)
                } label: {
                    Text(vm.senButtonTitle).frame(maxWidth: .infinity)
                }
                .keyboardShortcut(.defaultAction)
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .navigationTitle("Edit message")
        .navigationBarBackButtonHidden()

        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    vm.deleteMessage(completion: dismiss)
                } label: {
                    Image(systemName: "trash").foregroundColor(Color.red)
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { presentationMode.wrappedValue.dismiss() }
            }
        }

        .alert(vm.errorAlertMessage, isPresented: $vm.errorAlertDisplayed) {}
    }
}

struct EditMessageView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditMessageView(vm: EditMessageViewModel(message: Message.sample))
        }
    }
}
