//
//  SettingsView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import SwiftUI

// enum Setting: String, CaseIterable, Identifiable {
//    case myProfile, myCoach, logout
//    var id: Self { self }
// }

struct SettingsView: View {
    @EnvironmentObject var session: UserSession

    @State var signOutError = false

    var body: some View {
        NavigationView {
            Form {
                NavigationLink {
//                    Text("ProfileView")
//                    ProfileViewInit()
//                    ViewLoader2 {
//                        try await API.shared.store.loadProfile(userId: session.userId)
//                    } content: { profile in
//                        ProfileView(vm: ProfileViewModel(profile: profile))
//                    }
//                    ViewLoader(asyncData:
//                        AsyncDataFromPublisher { API.shared.profile.future(userId: session.userId) }
//                    ) {
//                        ProfileView(vm: ProfileViewModel(profile: $0))
//                    }
//                    ViewLoader(asyncData:
//                        AsyncDataFromPublisher2(API.shared.profile.future(userId: session.userId))
//                    ) {
//                        ProfileView(vm: ProfileViewModel(profile: $0))
//                    }
                    ViewLoader(asyncData:
                        AsyncDataFromLoader { try await API.shared.profile.load(userId: session.userId) }
                    ) {
                        ProfileView(vm: ProfileViewModel(profile: $0))
                    }
//                    ViewLoader(asyncData:
//                        AsyncDataFromPublisher(
//                            //                            dataPublisher: API.shared.store.profileFuture(userId: session.userId)
//                            dataPublisher: API.shared.profile.future(id: session.userId)
//                                .map { ProfileViewModel(profile: $0) }
//                                .eraseToAnyPublisher()
//                        )) { viewModel in
//                            ProfileView(vm: viewModel)
//                        }
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
//            .navigationViewStyle(StackNavigationViewStyle())
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
