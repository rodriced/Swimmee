//
//  CoachMessagesView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 09/10/2022.
//

import SwiftUI

class CoachMessagesViewModel: ObservableObject {
    @Published var items: [Message] = {
        var messages = Message.sample.toSamples(2)
        messages[1].isUnread = false
        return messages
    }()
    
    func removeItem(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
}

struct CoachMessagesView: View {
    @StateObject var vm = CoachMessagesViewModel()
//    @State var newMessage: Message?

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
//                Text("You have 1 new message(s)")
                List {
                    ForEach($vm.items) { $message in

//                        NavigationLink(destination: {EditMessageView(vm: EditMessageViewModel())}) {
//                            MessageView(message: message)
//                        }
                        NavigationLink() {
                            EditMessageView(vm: EditMessageViewModel())
//                            EditMessageView2(message: $message, messages: $vm.items)

                        } label: {
                            MessageView(message: message)
                        }
                        .listRowSeparator(.hidden)
                    }
                    .onDelete(perform: vm.removeItem)
                }
                .listStyle(.plain)
                .toolbar {
                    NavigationLink {
                        EditMessageView(vm: EditMessageViewModel())
                    } label: {
                        Image(systemName: "plus")
                    }
                }

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
    }
}

struct CoachMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        CoachMessagesView()
    }
}
