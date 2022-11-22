//
//  SwimmerMainView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 09/10/2022.
//

import Combine
import SwiftUI

class SwimmerMainVM: ObservableObject {
    @Published var newWorkoutsCount = 2
    @Published var unreadMessagesCount: String? {
        didSet {
            print("SwimmerMainVM.unreadMessagesCount.didSet : \(unreadMessagesCount.debugDescription)")
        }
    }

    init() {
        print("SwimmerMainVM.init")
    }

    deinit {
        print("SwimmerMainVM.deinit")
    }

    var unreadMessagesCountPublisher: AnyPublisher<Int, Error>?

    func startListeners(unreadMessagesCountPublisher: AnyPublisher<Int, Error>) {
        print("SwimmerMainVM.startListeners")

        self.unreadMessagesCountPublisher = unreadMessagesCountPublisher

        self.unreadMessagesCountPublisher?
            .map(formatUnreadMessagesCount)
            .replaceError(with: nil)
            .filter { $0 != self.unreadMessagesCount }
            .assign(to: &$unreadMessagesCount)
    }

    func formatUnreadMessagesCount(_ value: Int) -> String? {
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
            SwimmerWorkoutsView()
                .badge(vm.newWorkoutsCount)
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
                    content: SwimmerMessagesView.init
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
        .task { vm.startListeners(unreadMessagesCountPublisher: session.unreadMessagesCountPublisher) }
        .navigationViewStyle(.stack)
//            .animation(.easeIn, value: 1)
    }
}

struct SwimmerMainView_Previews: PreviewProvider {
    static var previews: some View {
        SwimmerMainView()
    }
}
