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

//        func assignIfNecessary(to newState: Self) {
//            if self != newState { self = newState }
//        }
    }

    @Published var state = LodingState.idle

//    @Published var targetVM = CoachMessagesViewModel()
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

class CoachMessagesViewModel: ObservableObject {
    @Published var messages: [Message]

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

struct CoachMessagesView: View {
    @EnvironmentObject var session: UserSession
    @ObservedObject var vm: CoachMessagesViewModel
//    @StateObject var vm: CoachMessagesViewModel

    init(vm: CoachMessagesViewModel) {
        print("CoachMessagesViewModel.init")
//        self._vm = StateObject(wrappedValue: vm)
        self._vm = ObservedObject(wrappedValue: vm)
    }

    var body: some View {
        VStack(spacing: 30) {
            DebugHelper.viewBodyPrint("CoachMessagesViewModel.body")
            List {
                ForEach($vm.messages) { $message in
                    NavigationLink {
                        EditMessageView(vm: EditMessageViewModel(message: message))
                    } label: {
                        MessageView(message: message, inReception: session.isSwimmer)
                    }
                    .listRowSeparator(.hidden)
                }
                .onDelete(perform: vm.deleteMessage)
            }
            .listStyle(.plain)
            .toolbar {
                NavigationLink {
                    EditMessageView(vm: EditMessageViewModel(userId: session.userId))
                } label: {
                    Image(systemName: "plus")
                }
            }
            .alert(vm.errorAlertMessage, isPresented: $vm.errorAlertDisplayed) {}
        }
        .navigationBarTitle("Messages", displayMode: .inline)
    }
}

struct CoachMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        CoachMessagesView(vm: CoachMessagesViewModel())
            .environmentObject(UserSession(initialProfile: Profile.coachSample))
    }
}
