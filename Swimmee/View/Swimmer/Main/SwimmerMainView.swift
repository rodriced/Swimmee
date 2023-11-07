//
//  SwimmerMainView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 09/10/2022.
//

import Combine
import SwiftUI

struct SwimmerMainView: View {
    @StateObject var router = UserRouter()
    @StateObject var session: SwimmerSession

    @StateObject var viewModel = SwimmerMainViewModel()

    init(profile: Profile) {
        _session = StateObject(wrappedValue: SwimmerSession(initialProfile: profile))
    }

    var body: some View {
        TabView(selection: $router.tabsTarget) {

            //
            // Workouts tab
            //

            NavigationView {
                LoadingView(
                    publisherBuiler: {
                        Publishers.CombineLatest(
                            session.workoutsPublisher,
                            session.readWorkoutsIdsPublisher
                        )
                        .eraseToAnyPublisher()
                    },
                    targetView: SwimmerWorkoutsView.init
                )
            }
            .navigationViewStyle(.stack)
            .badge(viewModel.unreadWorkoutsCount)
            .tabItem {
                Label("Workouts", systemImage: "stopwatch")
            }
            .tag(UserRouter.TabTarget.workouts)

            //
            // Messages tab
            //

            NavigationView {
                LoadingView(
                    publisherBuiler: {
                        Publishers.CombineLatest(
                            session.messagesPublisher,
                            session.readMessagesIdsPublisher
                        )
                        .eraseToAnyPublisher()
                    },
                    targetView: SwimmerMessagesView.init
                )
            }
            .navigationViewStyle(.stack)
            .badge(viewModel.unreadMessagesCount)
            .tabItem {
                Label("Messages", systemImage: "mail.stack")
            }
            .tag(UserRouter.TabTarget.messages)

            //
            // Settings tab
            //

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

        .task {
            session.listenChanges()
        }
        .task {
            viewModel.startListeners(
                unreadWorkoutsCountPublisher: session.unreadWorkoutsCountPublisher.eraseToAnyPublisher(),
                unreadMessagesCountPublisher: session.unreadMessagesCountPublisher.eraseToAnyPublisher()
            )
        }
    }
}

struct SwimmerMainView_Previews: PreviewProvider {
    static var previews: some View {
        SwimmerMainView(profile: Profile.swimmerSample)
    }
}
