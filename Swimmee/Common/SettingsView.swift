//
//  SettingsView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import SwiftUI

//enum Setting: String, CaseIterable, Identifiable {
//    case myProfile, myCoach, logout
//    var id: Self { self }
//}

struct SettingsView: View {
    @EnvironmentObject var userSession: UserSession

    @State var signOutError = false

    var body: some View {
        NavigationView {
            Form {
                NavigationLink(destination: { ProfileViewInit() }) {
                    MenuLabel(title: "My profile", systemImage: "person", color: Color.mint)
                }
                switch userSession.profile.userType {
                case .coach:
                    NavigationLink(destination: { CoachTeamView() }) {
                        MenuLabel(title: "My team", systemImage: "person.3", color: Color.blue)
                    }
                case .swimmer:
                    NavigationLink(destination: { SwimmerCoachView() }) {
                        MenuLabel(title: "My coach", systemImage: "person.2", color: Color.blue)
                    }
                }
                Button(action: { signOutError = !Service.shared.auth.signOut() }) {
                    MenuLabel(title: "Logout", systemImage: "rectangle.portrait.and.arrow.right", color: Color.orange)
                }
            }
            .navigationBarTitle("Settings")
//            .navigationViewStyle(StackNavigationViewStyle())
            .alert("Sign out Error", isPresented: $signOutError) {}
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(Session())
    }
}
