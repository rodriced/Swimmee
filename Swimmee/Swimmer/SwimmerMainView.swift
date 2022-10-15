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
            SwimmerMessagesView()
                .badge(vm.unreadMessagescount)
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

struct SwimmerMainView_Previews: PreviewProvider {
    static var previews: some View {
        SwimmerMainView()
    }
}
