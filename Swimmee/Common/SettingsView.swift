//
//  SettingsView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var session: UserSession

    @State var logoutConfirmationDialogIsPresented = false
    @State var signOutErrorAlertIsPresented = false

    var logoutConfirmationDialog: ConfirmationDialog {
        ConfirmationDialog(
            title: "You are going to logout from Swimmee.",
            primaryButton: "Confirm logout",
            primaryAction: {
                signOutErrorAlertIsPresented = !API.shared.account.signOut()
            }
        )
    }

    var body: some View {
        NavigationView {
            Form {
                NavigationLink {
                    LoadingView(
                        publisherBuiler: {
                            session.profileFuture
                        },
                        targetView: ProfileView.init
                    )
                } label: {
                    MenuLabel(title: "My profile", systemImage: "person", color: Color.mint)
                }

                switch session.userType {
                case .coach:
                    NavigationLink {
                        CoachTeamView()
                    } label: {
                        MenuLabel(title: "My team", systemImage: "person.3", color: Color.blue)
                    }
                case .swimmer:
                    NavigationLink {
                        SwimmerCoachView()
                    } label: {
                        MenuLabel(title: "My coach", systemImage: "person.2", color: Color.blue)
                    }
                }

                Button {
                    logoutConfirmationDialogIsPresented = true
                } label: {
                    MenuLabel(title: "Logout", systemImage: "rectangle.portrait.and.arrow.right", color: Color.orange)
                }
                .actionSheet(isPresented: $logoutConfirmationDialogIsPresented) {
                    logoutConfirmationDialog.actionSheet()
                }
            }
            .navigationBarTitle("Settings")
            .alert("Sign out Error", isPresented: $signOutErrorAlertIsPresented) {}
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
