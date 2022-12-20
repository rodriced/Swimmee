//
//  SwimmerMainView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 09/10/2022.
//

import Combine
import SwiftUI

class SwimmerMainViewModel: ObservableObject {
    @Published var newWorkoutsCount: String?
    @Published var unreadWorkoutsCount: String?
    @Published var unreadMessagesCount: String?
//    {
//        didSet {
//            print("SwimmerMainViewModel.unreadMessagesCount.didSet : \(unreadMessagesCount.debugDescription)")
//        }
//    }

//    init() {
//        print("SwimmerMainViewModel.init")
//    }
//
//    deinit {
//        print("SwimmerMainViewModel.deinit")
//    }

    var unreadWorkoutsCountPublisher: AnyPublisher<Int, Error>?
    var unreadMessagesCountPublisher: AnyPublisher<Int, Error>?

    func startListeners(unreadWorkoutsCountPublisher: AnyPublisher<Int, Error>,
                        unreadMessagesCountPublisher: AnyPublisher<Int, Error>)
    {
//        print("SwimmerMainViewModel.startListeners")

        self.unreadWorkoutsCountPublisher = unreadWorkoutsCountPublisher
        self.unreadMessagesCountPublisher = unreadMessagesCountPublisher

        self.unreadWorkoutsCountPublisher?
            .map(formatUnreadCount)
            .replaceError(with: nil)
            .filter { $0 != self.unreadWorkoutsCount }
            .assign(to: &$unreadWorkoutsCount)

        self.unreadMessagesCountPublisher?
            .map(formatUnreadCount)
            .replaceError(with: nil)
            .filter { $0 != self.unreadMessagesCount }
            .assign(to: &$unreadMessagesCount)
    }

    func formatUnreadCount(_ value: Int) -> String? {
        value > 0 ? String(value) : nil
    }
}

struct SwimmerMainView: View {
    @StateObject var session: SwimmerSession
    @StateObject var vm = SwimmerMainViewModel()
    
    @StateObject var router = UserRouter()

    init(profile: Profile) {
//        print("SwimmerMainView.init")
        _session = StateObject(wrappedValue: SwimmerSession(initialProfile: profile))
    }

    var body: some View {
        TabView(selection: $router.tabsTarget) {
            NavigationView {
                LoadingView(
                    publisherBuiler: {
                        Publishers.CombineLatest(
                            session.workoutsPublisher,
                            session.readWorkoutsIdsPublisher
                        )
                        .eraseToAnyPublisher()
                    }, // TODO: Manage error when there is no chosen coach
                    targetView: SwimmerWorkoutsView.init
                )
            }
            .navigationViewStyle(.stack)
            .badge(vm.unreadWorkoutsCount)
            .tabItem {
                Label("Workouts", systemImage: "stopwatch")
            }
            .tag(UserRouter.TabTarget.workouts)

            NavigationView {
                LoadingView(
                    publisherBuiler: {
                        Publishers.CombineLatest(
                            session.messagesPublisher,
                            session.readMessagesIdsPublisher
                        )
                        .eraseToAnyPublisher()
                    }, // TODO: Manage error when there is no chosen coach
                    targetView: SwimmerMessagesView.init
                )
            }
            .navigationViewStyle(.stack)
            .badge(vm.unreadMessagesCount)
            .tabItem {
                Label("Messages", systemImage: "mail.stack")
            }
            .tag(UserRouter.TabTarget.messages)

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
        .task {
            session.listenChanges()
        }
        .task {
            vm.startListeners(
                unreadWorkoutsCountPublisher: session.unreadWorkoutsCountPublisher.eraseToAnyPublisher(),
                unreadMessagesCountPublisher: session.unreadMessagesCountPublisher.eraseToAnyPublisher()
            )
        }
        .environmentObject(session)
    }
}

struct SwimmerMainView_Previews: PreviewProvider {
    static var previews: some View {
        SwimmerMainView(profile: Profile.swimmerSample)
    }
}
