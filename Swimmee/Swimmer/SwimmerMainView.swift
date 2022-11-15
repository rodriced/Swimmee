//
//  SwimmerMainView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 09/10/2022.
//

import SwiftUI

class SwimmerMainVM: ObservableObject {
    @Published var newWorkoutsCount = 2
    @Published var unreadMessagescount = 1
}

struct SwimmerMainView: View {
    @StateObject var vm = SwimmerMainVM()

    var body: some View {
        TabView {
            SwimmerWorkoutsView()
                .badge(vm.newWorkoutsCount)
                .tabItem {
                    Label("Workouts", systemImage: "stopwatch")
                }
            NavigationView {
                LoadingView(publisherBuiler: { API.shared.message.listPublisher(owner: .user("F0VE3g0aZCbjmuK4GzUkO6KxkPI2"), isSended: .sended) }, content: SwimmerMessagesView.init)
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
