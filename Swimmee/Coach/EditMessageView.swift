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

    func saveMessage(andSendIt: Bool, presentationMode: Binding<PresentationMode>) {
        Task {
            message.isSended = andSendIt
            do {
                _ = try await API.shared.message.save(message)
                presentationMode.wrappedValue.dismiss()
            } catch {
                errorAlertMessage = error.localizedDescription
            }
        }
    }

    func deleteMessage(presentationMode: Binding<PresentationMode>) {
        guard let dbId = message.dbId else {
            presentationMode.wrappedValue.dismiss()
            return
        }

        Task {
            do {
                try await API.shared.message.delete(id: dbId)
                presentationMode.wrappedValue.dismiss()
            } catch {
                errorAlertMessage = error.localizedDescription
            }
        }
    }
}

struct EditMessageView: View {
    @ObservedObject var vm: EditMessageViewModel
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack {
            Form {
                Section {
                    TextField("Title", text: $vm.message.title)
                }
                TextEditorWithPlaceholder(text: $vm.message.content, placeholder: "Content", height: 400)
            }

            HStack {
                Button {
                    vm.saveMessage(andSendIt: false, presentationMode: presentationMode)
                } label: {
                    Text("Save as draft").frame(maxWidth: .infinity)
                }
                .foregroundColor(Color.black)
                .tint(Color.orange.opacity(0.7))

                Button {
                    vm.saveMessage(andSendIt: true, presentationMode: presentationMode)
                } label: {
                    Text("Send").frame(maxWidth: .infinity)
                }
                .keyboardShortcut(.defaultAction)
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .navigationTitle("Edit message")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    vm.deleteMessage(presentationMode: presentationMode)
                } label: {
                    Image(systemName: "trash").foregroundColor(Color.red)
                }
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
