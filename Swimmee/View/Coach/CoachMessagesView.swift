//
//  CoachMessagesView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 09/10/2022.
//

import SwiftUI

struct CoachMessagesView: View {
    @EnvironmentObject var userInfos: UserInfos
    @EnvironmentObject var session: CoachSession
    
    @ObservedObject var viewModel: CoachMessagesViewModel

    init(viewModel: CoachMessagesViewModel) {
//        print("CoachMessagesView.init")
        _viewModel = ObservedObject(initialValue: viewModel)
    }

    var messagesList: some View {
        List {
            ForEach(viewModel.filteredMessages) { message in
                NavigationLink(tag: message, selection: $viewModel.selectedMessage) {
                    EditMessageView(message: message)
                } label: {
                    MessageView(message: message, inReception: false)
                }
                .listRowSeparator(.hidden)
            }
            .onDelete(perform: viewModel.deleteMessage)
        }
        .listStyle(.plain)
    }

    var filterStateIndication: some View {
        Group {
            if viewModel.filter != .all {
                (
                    Text("Filter enabled : ")
                        .foregroundColor(.secondary)
                        + Text(viewModel.filter.rawValue)
                        .foregroundColor(viewModel.filter == .draft ? .orange : .mint)
                        .bold()
                )
                .font(Font.system(.caption))
            }
        }
    }

    var filterMenu: some View {
        Menu {
            Picker("Filter", selection: $viewModel.filter) {
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
            EditMessageView(message: Message(userId: userInfos.userId))
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
//            DebugHelper.viewBodyPrint("CoachMessagesView.body")

            if viewModel.messages.isEmpty {
                emptyListInformation
            } else {
                filterStateIndication
                messagesList
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if !viewModel.messages.isEmpty {
                    filterMenu
                }

                editNewMessageButton
            }
        }
        .actionSheet(isPresented: $viewModel.sentMessageEditionConfirmationDialogPresented) {
            ActionSheet(
                title: Text("Edit an already sent message ?"),
                message: Text("Message will stay sent until you save it as draft or delete it."),
                buttons: [
                    .default(Text("Edit"), action: {
                        viewModel.navigatingToEditView = true
                    }),
                    .cancel()
                ]
            )
        }
        .alert(viewModel.alertContext) {}
        .navigationBarTitle("Messages", displayMode: .inline)
    }
}

struct CoachMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        CoachMessagesView(viewModel: CoachMessagesViewModel(initialData: [Message.sample]))
            .environmentObject(UserInfos(profile: Profile.coachSample))
            .environmentObject(CoachSession())
    }
}
