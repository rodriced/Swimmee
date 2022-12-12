//
//  CoachMessagesView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 09/10/2022.
//

import Combine
import SwiftUI

enum CoachMessagesFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case draft = "Draft only"
    case sent = "Sent only"

    var id: Self { self }
}

class CoachMessagesViewModel: ObservableObject {
    struct Config: ViewModelConfig {
        let messageAPI: UserMessageCollectionAPI
        
        static let `default` = Config(messageAPI: API.shared.message)
    }
    
    let config: Config

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

    required init(initialData: [Message], config: Config = .default) {
        print("CoachMessagesViewModel.init")
        messages = initialData
        self.config = config
    }

    var restartLoader: (() -> Void)?

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
                messages.remove(atOffsets: offsets)
            } catch {
                alertContext.message = error.localizedDescription
            }
        }
    }
}

extension CoachMessagesViewModel: LoadableViewModel {
    typealias LoadedData = [Message]

    func refreshedLoadedData(_ loadedData: [Message]) {
        messages = loadedData
    }
}

struct CoachMessagesView: View {
    @EnvironmentObject var session: UserSession
    @ObservedObject var vm: CoachMessagesViewModel
//    @StateObject var vm: CoachMessagesViewModel

    init(vm: CoachMessagesViewModel) {
        print("CoachMessagesView.init")
//        self._vm = StateObject(wrappedValue: vm)
        _vm = ObservedObject(initialValue: vm)
    }

    var messagesList: some View {
//        if let selectedMessage = vm.selectedMessage {
//            NavigationLink(isActive: $vm.navigatingToEditView) {
//                EditMessageView(message: selectedMessage)
//            } label: {
//                EmptyView()
//            }
//        }

        List {
            ForEach(vm.filteredMessages) { message in
                NavigationLink(tag: message, selection: $vm.selectedMessage) {
                    EditMessageView(message: message)
                } label: {
                    MessageView(message: message, inReception: session.isSwimmer)
                }
//                Button {
//                    vm.goEditingMessage(message)
//                } label: {
//                    HStack {
//                        MessageView(message: message, inReception: session.isSwimmer)
//                        Image(systemName: "chevron.forward")
//                            .font(Font.system(.footnote))
//                            .foregroundColor(Color.gray)
//                    }
//                }
                .listRowSeparator(.hidden)
            }
            .onDelete(perform: vm.deleteMessage)
        }
        .listStyle(.plain)
    }

    var filterStateIndication: some View {
        Group {
            if vm.filter != .all {
                (
                    Text("Filter enabled : ")
                        .foregroundColor(.secondary)
                        + Text(vm.filter.rawValue)
                        .foregroundColor(vm.filter == .draft ? .orange : .mint)
                        .bold()
                )
                .font(Font.system(.caption))
            }
        }
    }

    var filterMenu: some View {
        Menu {
            Picker("Filter", selection: $vm.filter) {
                ForEach(CoachMessagesFilter.allCases) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
//            .pickerStyle(.inline)
        } label: {
            Label("Filter", systemImage: "slider.horizontal.3")
        }
    }

    var editNewMessageButton: some View {
        NavigationLink {
            EditMessageView(message: Message(userId: session.userId))
        } label: {
            Image(systemName: "plus")
        }
    }

    var emptyListInformation: some View {
        VStack(spacing: 10) {
            Text("No messages.")
            HStack {
                Text("Use")
                editNewMessageButton
                    .foregroundColor(.accentColor)
                    .shadow(radius: 5)
                Text("button to create one.")
            }
        }
        .foregroundColor(.secondary)
    }

    var body: some View {
        VStack(spacing: 30) {
            DebugHelper.viewBodyPrint("CoachMessagesView.body")

            if vm.messages.isEmpty {
                emptyListInformation
            } else {
                filterStateIndication
                messagesList
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if !vm.messages.isEmpty {
                    filterMenu
                }

                editNewMessageButton
            }
        }
        .actionSheet(isPresented: $vm.sentMessageEditionConfirmationDialogPresented) {
            ActionSheet(
                title: Text("Edit an already sent message ?"),
                message: Text("Message will stay sent until you save it as draft or delete it."),
                buttons: [
                    .default(Text("Edit"), action: {
                        vm.navigatingToEditView = true
                    }),
                    .cancel()
                ]
            )
        }
        .alert(vm.alertContext) {}
        .navigationBarTitle("Messages", displayMode: .inline)
    }
}

struct CoachMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        CoachMessagesView(vm: CoachMessagesViewModel(initialData: [Message.sample]))
            .environmentObject(UserSession(initialProfile: Profile.coachSample))
    }
}
