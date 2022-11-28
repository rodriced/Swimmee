//
//  SettingsView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var session: UserSession

    @State var signOutError = false

    var body: some View {
        NavigationView {
            Form {
                NavigationLink {
                    LoadingViewV2(
                        publisherBuiler: {
                            API.shared.profile.future(userId: nil)
                        },
                        content: ProfileView.init
                    )
                } label: {
                    MenuLabel(title: "My profile", systemImage: "person", color: Color.mint)
                }
                
                switch session.userType {
                case .coach:
                    NavigationLink(destination: { CoachTeamView() }) {
                        MenuLabel(title: "My team", systemImage: "person.3", color: Color.blue)
                    }
                case .swimmer:
                    NavigationLink(destination: { SwimmerCoachView() }) {
                        MenuLabel(title: "My coach", systemImage: "person.2", color: Color.blue)
                    }
                }
                
                Button(action: { signOutError = !API.shared.auth.signOut() }) {
                    MenuLabel(title: "Logout", systemImage: "rectangle.portrait.and.arrow.right", color: Color.orange)
                }
            }
            .navigationBarTitle("Settings")
            .alert("Sign out Error", isPresented: $signOutError) {}
        }
        .navigationViewStyle(.stack)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(Session())
    }
}
