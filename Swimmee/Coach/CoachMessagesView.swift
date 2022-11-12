//
//  CoachMessagesView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 09/10/2022.
//

import SwiftUI
import Combine

class CoachMessagesViewModel: ObservableObject {
    @Published var messages: [Message] = {
        var messages = Message.sample.toSamples(2)
        messages[1].isUnread = false
        return messages
    }()

    @Published var errorAlertDisplayed = false {
        didSet { if !errorAlertDisplayed { errorAlertMessage = "" } }
    }

    @Published var errorAlertMessage: String = "" {
        didSet { errorAlertDisplayed = !errorAlertMessage.isEmpty }
    }

//    func loadMessages() {
//
//    }

    func removeMessage(at offsets: IndexSet) {
        messages.remove(atOffsets: offsets)
    }
}

struct CoachMessagesView: View {
    @EnvironmentObject var session: UserSession
    @StateObject var vm = CoachMessagesViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
//                Text("You have 1 new message(s)")
                List {
                    ForEach($vm.messages) { $message in

//                        NavigationLink(destination: {EditMessageView(vm: EditMessageViewModel())}) {
//                            MessageView(message: message)
//                        }
                        NavigationLink {
                            EditMessageView(vm: EditMessageViewModel(message: message))

                        } label: {
                            MessageView(message: message)
                        }
                        .listRowSeparator(.hidden)
                    }
                    .onDelete(perform: vm.removeMessage)
                }
//                .task {
//                    do {
//                        print("load messages")
//                        vm.messages = try await API.shared.message.loadList(userId: session.userId)
//                    } catch {
//                        vm.errorAlertMessage = error.localizedDescription
//                    }
//                }
                .onReceive(
//                    API.shared.message.listPublisher(userId: session.userId)
                    API.shared.message.listPublisher()
//                    .catch { Just([Message(userId: "", title: "Error", content: $0.localizedDescription, isUnread: false)])}
                        .map {Result.success($0)}
                        .catch {Just(Result.failure($0))}
                ){ result in
                    print("listPublisher reveive : \(String(describing: result))")
                    switch result {
                    case .success(let messages):
                        vm.messages = messages
                    case .failure(let error):
                        vm.errorAlertMessage = error.localizedDescription
                    }
//                    messages in
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
//            .padding()
            .navigationBarTitle("Messages", displayMode: .inline)

//            VStack(spacing: 30) {
//                Text("You have 1 new message(s)")
//                ScrollView {
//                    VStack(spacing: 20) {
//                        ForEach($vm.items) { $message in
//
//                            MessageView(message: message)
//
//                        }
//                        .onDelete(perform: vm.removeItem)
//                    }
//                }
//            }
//            .padding()
//            .navigationBarTitle("Messages", displayMode: .inline)
        }
        .navigationViewStyle(.stack)
    }
}

struct CoachMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        CoachMessagesView()
            .environmentObject(UserSession(profile: Profile.coachSample))
    }
}
