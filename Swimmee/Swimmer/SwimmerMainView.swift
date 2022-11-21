//
//  SwimmerMainView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 09/10/2022.
//

import Combine
import SwiftUI

class SwimmerMainVM: ObservableObject {
    @Published var newWorkoutsCount = 2
    @Published var unreadMessagescount = 1
}

struct SwimmerMainView: View {
    @EnvironmentObject var session: UserSession
    @StateObject var vm = SwimmerMainVM()

    var body: some View {
        TabView {
            SwimmerWorkoutsView()
                .badge(vm.newWorkoutsCount)
                .tabItem {
                    Label("Workouts", systemImage: "stopwatch")
                }
            NavigationView {
                LoadingView(
                    publisherBuiler: {
                        session.$coachId.flatMap { coachId -> AnyPublisher<[Message], Error> in
                            API.shared.message.listPublisher(owner: .user(coachId ?? ""), isSended: .sended)
                        }
                        .combineLatest(session.$readMessagesIds.setFailureType(to: Error.self))
                        .eraseToAnyPublisher()
                    }, // TODO: Manage error when there is no chosen coach
                   content: SwimmerMessagesView.init
                )
            }
            .badge(vm.unreadMessagescount)
            .tabItem {
                Label("Messages", systemImage: "mail.stack")
            }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .navigationViewStyle(.stack)
//            .animation(.easeIn, value: 1)
    }
}

struct SwimmerMainView_Previews: PreviewProvider {
    static var previews: some View {
        SwimmerMainView()
    }
}
