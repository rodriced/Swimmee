//
//  SwimmerMessagesView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 09/10/2022.
//

import SwiftUI

class SwimmerMessagesViewModel {
    @Published var messages: [Message] = []
    @Published var newMessagesCount: Int = 0
    //    @AppStorage("read_messages_ids_string") var readMessagesIdsString: String?
    //
    //    var readMessagesIds: [String] {
    //        get {
    //            return (readMessagesIdsString ?? "").components(separatedBy: ",")
    //        }
    //        set(newReadMessagesIds) {
    //            readMessagesIdsString = newReadMessagesIds.joined(separator: ",")
    //        }
    //    }
    @Published var readMessagesIds: Set<String> {
        didSet {
            print("SwimmerMessagesViewModel.readMessagesIds.didSet")
            UserDefaults.standard.set(readMessagesIds.joined(separator: ","), forKey: "read_messages_ids_string")
        }
    }

    required init() {
        print("SwimmerMessagesViewModel.init")
        let readMessagesIdsString = UserDefaults.standard.string(forKey: "read_messages_ids_string") ?? ""
        readMessagesIds = Set(readMessagesIdsString.components(separatedBy: ","))
    }
    
    var reload: (() -> Void)?

    func setMessageRead(_ message: Message) {
        guard let dbId = message.dbId else { return }
        readMessagesIds.insert(dbId)
//        var updatedMessage = message
//        updatedMessage.isUnread = false
//        if let i = messages.firstIndex(where: { $0.dbId == message.dbId }) {
//            messages[i].isUnread = false
//
//        }
    }
    
    func isMessageRead(_ message: Message) -> Bool {
        message.dbId.map {readMessagesIds.contains($0)} ?? false
    }
}

extension SwimmerMessagesViewModel: LoadableViewModel {
    func injectLoadedData(_ loadedData: [Message]) {
        messages = loadedData
    }
}

struct SwimmerMessagesView: View {
    typealias ViewModel = SwimmerMessagesViewModel

    @ObservedObject var vm: SwimmerMessagesViewModel

    init(_ vm: SwimmerMessagesViewModel) {
//        print("SwimmerhMessagesViewModel.init")
        _vm = ObservedObject(wrappedValue: vm)
    }

    var body: some View {
        VStack(spacing: 30) {
            Text("You have 1 new message(s)")

            List(vm.messages) { message in
                MessageView(message: message, isRead: vm.isMessageRead(message))
                    .listRowSeparator(.hidden)
                    .onTapGesture {
                        vm.setMessageRead(message)
                    }
            }
            .refreshable { vm.reload?() }
        }
        .listStyle(.plain)

//            VStack(spacing: 30) {
//                Text("You have 1 new message(s)")
//                ScrollView {
//                    VStack(spacing: 20) {
//                        ForEach($vm.items) { $message in
//
//                            MessageView(message: message)
//                        }
//                    }
//                }
//            }
        .padding()
        .navigationBarTitle("Messages", displayMode: .inline)
    }
}

// struct SwimmerMessagesView_Previews: PreviewProvider {
//    static var previews: some View {
//        SwimmerMessagesView()
//    }
// }
