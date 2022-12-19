//
//  SettingsView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var userInfos: UserInfos
    @EnvironmentObject var router: UserRouter

    @State var logoutConfirmationIsPresented = false
    @State var alertContext = AlertContext()

    var body: some View {
        Form {
            NavigationLink(tag: UserRouter.SettingTarget.profile, selection: $router.settingsTarget) {
                LoadingView(
                    publisherBuiler: {
                        userInfos.profileFuture
                    },
                    targetView: ProfileView.init
                )
            } label: {
                MenuLabel(title: "My profile", systemImage: "person", color: Color.mint)
            }

            switch userInfos.userType {
            case .coach:
                NavigationLink(tag: UserRouter.SettingTarget.team, selection: $router.settingsTarget) {
                    CoachTeamView()
                } label: {
                    MenuLabel(title: "My team", systemImage: "person.3", color: Color.blue)
                }
            case .swimmer:
                NavigationLink(tag: UserRouter.SettingTarget.coachSelection, selection: $router.settingsTarget) {
                    SwimmerCoachView()
                } label: {
                    MenuLabel(title: "My coach", systemImage: "person.2", color: Color.blue)
                }
            }

            Button {
                logoutConfirmationIsPresented = true
            } label: {
                MenuLabel(title: "Logout", systemImage: "rectangle.portrait.and.arrow.right", color: Color.orange)
            }
            .confirmationDialog("You are going to logout from Swimmee.", isPresented: $logoutConfirmationIsPresented) {
                Button("Confirm logout") {
                    if API.shared.account.signOut() == false {
                        alertContext.message = "Sign out Error"
                    }
                }
            }
//
//            Section {
//                Button {
//                    fatalError("Crash forced for Crashlytics test !")
//                } label: {
//                    MenuLabel(title: "Force crash", systemImage: "bolt.fill", color: Color.red)
//                }
//            }
        }
        .navigationBarTitle("Settings")
        .alert(alertContext) {}
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(Session())
    }
}
