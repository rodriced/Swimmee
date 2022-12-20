//
//  CoachMainView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 09/10/2022.
//

import SwiftUI

struct CoachMainView: View {
    @StateObject var router = UserRouter()
    @StateObject var session = CoachSession()

    var body: some View {
        TabView(selection: $router.tabsTarget) {
            
            NavigationView {
                LoadingView(
                    publisherBuiler: {
                        session.workoutsPublisher.eraseToAnyPublisher()
                    },
                    targetView: CoachWorkoutsView.init
                )
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Workouts", systemImage: "stopwatch")
            }
            .tag(UserRouter.TabTarget.workouts)

            NavigationView {
                LoadingView(
                    publisherBuiler: {
                        session.messagesPublisher.eraseToAnyPublisher()
                    },
                    targetView: CoachMessagesView.init
                )
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Messages", systemImage: "mail.stack")
            }
            .tag(UserRouter.TabTarget.messages)

            NavigationView {
                SettingsView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
            .tag(UserRouter.TabTarget.settings)
            
        }
        .environmentObject(router)
        .environmentObject(session)
    }
}

struct CoachMainView_Previews: PreviewProvider {
    static var previews: some View {
        CoachMainView()
    }
}
