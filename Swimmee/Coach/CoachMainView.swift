//
//  CoachMainView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 09/10/2022.
//

import SwiftUI

struct CoachMainView: View {
//    @EnvironmentObject var userInfos: UserInfos
    @StateObject var session = CoachSession()

//    init() {
////        print("SignedInView.init")
//        _session = StateObject(wrappedValue: CoachSession(initialProfile: profile))
//    }

    var body: some View {
        TabView {
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

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .environmentObject(session)
//            .animation(.easeIn, value: 1)
    }
}

struct CoachMainView_Previews: PreviewProvider {
    static var previews: some View {
        CoachMainView()
    }
}
