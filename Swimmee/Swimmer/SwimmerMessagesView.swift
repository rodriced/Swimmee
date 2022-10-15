//
//  SwimmerMessagesView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 09/10/2022.
//

import SwiftUI

class SwimmerMessagesViewModel: ObservableObject {
    @Published var items: [Message] = [
        Message(title: "Title 1", content: "Content 1", isUnread: true),
        Message(title: "Title 2", content: "Content 2\nBla bla bla", isUnread: false)
    ]
    
    func removeItem(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
}

struct SwimmerMessagesView: View {
    @StateObject var vm = SwimmerMessagesViewModel()

    var body: some View {
        NavigationView {
//            VStack(spacing: 30) {
//                Text("You have 1 new message(s)")
//                List {
//                    ForEach($vm.items) { $message in
//
//                        MessageView(message: message)
//                    }
//                    .onDelete(perform: vm.removeItem)
//                }
//
//            }

            VStack(spacing: 30) {
                Text("You have 1 new message(s)")
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach($vm.items) { $message in

                            MessageView(message: message)

                        }
                        .onDelete(perform: vm.removeItem)
                    }
                }
            }
            .padding()
            .navigationBarTitle("Messages", displayMode: .inline)
        }
    }
}

struct SwimmerMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        SwimmerMessagesView()
    }
}
