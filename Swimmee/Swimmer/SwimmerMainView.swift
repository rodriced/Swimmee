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
//    @StateObject var vm: SwimmerMainVM

    init() {
//        _vm = StateObject(wrappedValue: SwimmerMainVM(unreadMessagesCountPublisher: UserSession(initialProfile: Profile.coachSample).unreadMessagesCountPublisher))
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
                        session.$coachId.flatMap { coachId -> AnyPublisher<[Message], Error> in
                            API.shared.message.listPublisher(owner: .user(coachId ?? ""), isSended: .sended)
                        }
                        .combineLatest(session.$readMessagesIds.setFailureType(to: Error.self))
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
