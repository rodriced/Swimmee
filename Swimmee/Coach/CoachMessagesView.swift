//
//  CoachMessagesView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 09/10/2022.
//

import Combine
import SwiftUI

class CoachMessagesLoadingViewModel: ObservableObject {
    enum LodingState: Equatable {
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.loading, .loading), (.loaded, .loaded), (.failure(_), .failure(_)):
                return true
            default:
                return false
            }
        }

        case idle, loading, loaded, failure(Error)
    }

    @Published var state = LodingState.idle

    let targetVM = CoachMessagesViewModel()

    var cancellable: Cancellable?

    func load(messagesPublisher: AnyPublisher<[Message], Error>) {
        print("CoachMessagesLoadingViewModel.load")

        state = .loading

//        cancellable = API.shared.message.listPublisher(isSent: .any).asResult()
//        cancellable = API.shared.message.listPublisher(isSent: .any).asResult()
        cancellable = messagesPublisher.asResult()
//        cancellable = API.shared.message.listPublisherTest()
            .sink { [weak self] result in
                switch result {
                case .success(let messages):
                    self?.targetVM.messages = messages
                    if self?.state != .loaded { self?.state = .loaded }
//                    state.assignIfNecessary(to: .loaded)

                case .failure(let error):
                    self?.state = .failure(error)
                }
            }

//        cancellable = API.shared.message.listPublisher()
        ////        cancellable = API.shared.message.listPublisherTest()
//            .sink { [weak self] result in
//                switch result {
//                case .success(let messages):
//                    self?.targetVM.messages = messages
//                    if self?.state != .loaded { self?.state = .loaded }
        ////                    state.assignIfNecessary(to: .loaded)
//
//                case .failure(let error):
//                    self?.state = .failure(error)
//                }
//            }
    }

    init() {
        print("CoachMessagesLoadingViewModel.init")
    }
}

struct CoachMessagesLoadingView: View {
    @EnvironmentObject var session: UserSession

    @StateObject var loadingVM = CoachMessagesLoadingViewModel()

    init() {
        print("CoachMessagesLoadingView.init")
    }

    var body: some View {
        Group {
            DebugHelper.viewBodyPrint("CoachMessagesLoadingView.body state = \(loadingVM.state)")
            switch loadingVM.state {
            case .idle:
                Color.clear
                    .onAppear {
                        loadingVM.load(messagesPublisher: session.allMessagesPublisher.eraseToAnyPublisher())
                    }
            case .loading:
                ProgressView()
            case .loaded:
                CoachMessagesView(vm: loadingVM.targetVM)
            case .failure(let error):
                VStack {
                    Text("\(error.localizedDescription)\nVerify your connectivity\nand come back on this page.")
                    Button("Retry") {
                        loadingVM.state = .idle
                    }
                }
            }
        }
    }
}

enum CoachMessagesFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case draft = "Draft only"
    case sent = "Sent only"

    var id: Self { self }
}

class CoachMessagesViewModel: ObservableObject {
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
    @Published var confirmationDialogPresented = false
    @Published var navigatingToEditView = false

    @Published var errorAlertDisplayed = false {
        didSet { if !errorAlertDisplayed { errorAlertMessage = "" } }
    }

    var errorAlertMessage: String = "" {
        didSet { if !errorAlertMessage.isEmpty { errorAlertDisplayed = true } }
    }

    init(messages: [Message] = []) {
        print("CoachMessagesViewModel.init")

        self.messages = messages
    }

    func goEditingMessage(_ message: Message) {
        selectedMessage = message

        if message.isSent {
            confirmationDialogPresented = true
        } else {
            navigatingToEditView = true
        }
    }

    func deleteMessage(at offsets: IndexSet) {
        guard let index = offsets.first else { return }

        let messageToDelete = messages[index]

        Task {
            do {
                if let dbId = messageToDelete.dbId {
                    try await API.shared.message.delete(id: dbId)
                }
                messages.remove(atOffsets: offsets)
            } catch {
                errorAlertMessage = error.localizedDescription
            }
        }
    }
}

// extension

struct CoachMessagesView: View {
    @EnvironmentObject var session: UserSession
    @ObservedObject var vm: CoachMessagesViewModel
//    @StateObject var vm: CoachMessagesViewModel

    init(vm: CoachMessagesViewModel) {
        print("CoachMessagesView.init")
//        self._vm = StateObject(wrappedValue: vm)
        self._vm = ObservedObject(wrappedValue: vm)
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

    var body: some View {
        VStack(spacing: 30) {
            DebugHelper.viewBodyPrint("CoachMessagesView.body")

            if vm.messages.isEmpty {
                Text("No messages").foregroundColor(.secondary)
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

                NavigationLink {
                    EditMessageView(message: Message(userId: session.userId, title: String("afjsle,vopo".shuffled())))
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .actionSheet(isPresented: $vm.confirmationDialogPresented) {
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
        .alert(vm.errorAlertMessage, isPresented: $vm.errorAlertDisplayed) {}
        .navigationBarTitle("Messages", displayMode: .inline)
    }
}

struct CoachMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        CoachMessagesView(vm: CoachMessagesViewModel())
            .environmentObject(UserSession(initialProfile: Profile.coachSample))
    }
}
