//
//  SwimmerMessagesView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 09/10/2022.
//

import SwiftUI

class SwimmerMessagesViewModel: LoadableViewModel {
    @Published var messages: [Message] = []

    required init() {}

    func injectLoadedData(_ loadedData: [Message]) {
        messages = loadedData
    }
}

struct SwimmerMessagesView: View {
    typealias ViewModel = SwimmerMessagesViewModel
    
    @ObservedObject var vm: SwimmerMessagesViewModel
    
    init(_ vm: SwimmerMessagesViewModel) {
//        print("SwimmerhMessagesViewModel.init")
        self._vm = ObservedObject(wrappedValue: vm)
    }


    var body: some View {
        VStack(spacing: 30) {
            Text("You have 1 new message(s)")
            List {
                ForEach(vm.messages) { message in
                    MessageView(message: message)
                        .listRowSeparator(.hidden)
                }
            }
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

//struct SwimmerMessagesView_Previews: PreviewProvider {
//    static var previews: some View {
//        SwimmerMessagesView()
//    }
//}
