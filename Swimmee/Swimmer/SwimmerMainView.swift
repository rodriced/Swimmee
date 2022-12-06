//
//  SwimmerMainView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 09/10/2022.
//

import Combine
import SwiftUI

class SwimmerMainVM: ObservableObject {
    @Published var newWorkoutsCount: String?
    @Published var unreadWorkoutsCount: String?
    @Published var unreadMessagesCount: String?
//    {
//        didSet {
//            print("SwimmerMainVM.unreadMessagesCount.didSet : \(unreadMessagesCount.debugDescription)")
//        }
//    }

    init() {
        print("SwimmerMainVM.init")
    }

    deinit {
        print("SwimmerMainVM.deinit")
    }

    var unreadWorkoutsCountPublisher: AnyPublisher<Int, Error>?
    var unreadMessagesCountPublisher: AnyPublisher<Int, Error>?

    func startListeners(unreadWorkoutsCountPublisher: AnyPublisher<Int, Error>,
                        unreadMessagesCountPublisher: AnyPublisher<Int, Error>)
    {
        print("SwimmerMainVM.startListeners")

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
    @EnvironmentObject var session: UserSession
    @StateObject var vm = SwimmerMainVM()

    init() {
        print("SwimmerMainView.init")
    }

    var body: some View {
        TabView {
            NavigationView {
                LoadingView(
                    publisherBuiler: {
                        Publishers.CombineLatest(
                            session.workoutPublisher,
                            session.readWorkoutsIdsPublisher
                        )
                        .eraseToAnyPublisher()
                    }, // TODO: Manage error when there is no chosen coach
                    targetView: SwimmerWorkoutsView.init
                )
            }
            .badge(vm.unreadWorkoutsCount)
            .tabItem {
                Label("Workouts", systemImage: "stopwatch")
            }

            NavigationView {
                LoadingView(
                    publisherBuiler: {
                        Publishers.CombineLatest(
                            session.messagePublisher,
                            session.readMessagesIdsPublisher
                        )
                        .eraseToAnyPublisher()
                    }, // TODO: Manage error when there is no chosen coach
                    targetView: SwimmerMessagesView.init
                )
            }
            .badge(vm.unreadMessagesCount)
            .tabItem {
                Label("Messages", systemImage: "mail.stack")
            }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .task {
            vm.startListeners(
                unreadWorkoutsCountPublisher: session.unreadWorkoutsCountPublisher.eraseToAnyPublisher(),
                unreadMessagesCountPublisher: session.unreadMessagesCountPublisher.eraseToAnyPublisher()
            )
        }
        .navigationViewStyle(.stack)
//            .animation(.easeIn, value: 1)
    }
}

struct SwimmerMainView_Previews: PreviewProvider {
    static var previews: some View {
        SwimmerMainView()
    }
}
