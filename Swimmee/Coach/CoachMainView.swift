//
//  CoachMainView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 09/10/2022.
//

import SwiftUI

struct CoachMainView: View {
    var body: some View {
        TabView {
            CoachWorkoutsView()
                .tabItem {
                    Label("Workouts", systemImage: "stopwatch")
                }
            NavigationView {
                CoachMessagesLoadingView()
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
