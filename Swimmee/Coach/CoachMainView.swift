//
//  CoachMainView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 09/10/2022.
//

import SwiftUI

struct CoachMainView: View {
    @EnvironmentObject var session: UserSession

    var body: some View {
        TabView {
            NavigationView {
                LoadingView(
                    publisherBuiler: {
                        session.allWorkoutsPublisher.eraseToAnyPublisher()
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
                        session.allMessagesPublisher.eraseToAnyPublisher()
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
//            .animation(.easeIn, value: 1)
    }
}

struct CoachMainView_Previews: PreviewProvider {
    static var previews: some View {
        CoachMainView()
    }
}
