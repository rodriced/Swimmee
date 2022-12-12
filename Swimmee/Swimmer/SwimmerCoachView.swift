//
//  SwimmerCoachView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 11/10/2022.
//

import Combine
import SwiftUI

class SwimmerCoachViewModel: ObservableObject {
    let profileAPI: ProfileSwimmerAPI

    init(profileAPI: ProfileSwimmerAPI = API.shared.profile) {
        self.profileAPI = profileAPI
    }

    enum ViewState: Equatable {
        case loading
        case normal
        case info(String)
    }

    @Published var state = ViewState.loading

    @Published var coachs: [Profile] = []
    @Published var currentCoach: Profile?

    @Published var confirmationDialogPresented: ConfirmationDialog?

    @Published var alertContext = AlertContext()

    @MainActor
    func loadCoachs(withSelected coachId: UserId?) async {
        do {
            state = .loading

            let coachs = try await profileAPI.loadCoachs()

            guard !coachs.isEmpty else {
                state = .info("No coach available for now.\nCome back later.")
                return
            }

            guard let coachId else {
                self.coachs = coachs
                self.currentCoach = nil
                state = .normal
                return
            }

            let currentCoach = coachs.first { profile in
                profile.userId == coachId
            }

            guard currentCoach != nil else {
                state = .info("Can't find your coach in the list of available coachs.\nCome back later or ask administration for help.")
                return
            }

            self.coachs = coachs
            self.currentCoach = currentCoach
            state = .normal

        } catch {
            state = .info(error.localizedDescription)
        }
    }

    // TODO: For live update. To be tested...
//    var cancellable: AnyCancellable?
//
//    func listenCoachs(initialSelectedCoachId: UserId?) {
//        cancellable = profileAPI.coachsPublisher()
//            .sink(
//                receiveCompletion: { [weak self] in
//                    if case let .failure(error) = $0 {
//                        self?.errorAlertMessage = error.localizedDescription
//                    }
//                },
//                receiveValue: { [weak self] in
//                    guard let vm = self else { return }
//
//                    vm.coachs = $0
//
//                    guard let initialSelectedCoachId else {
//                        vm.currentCoach = nil
//                        return
//                    }
//                    vm.currentCoach = vm.coachs.first { profile in
//                        profile.userId == initialSelectedCoachId
//                    }
//                }
//            )
//    }

    func saveSelectedCoach(_ coach: Profile?) {
        Task {
            do {
                try await profileAPI.updateCoach(with: coach?.userId)
                await MainActor.run {
                    currentCoach = coach
                }
            } catch {
                await MainActor.run {
                    alertContext.message = error.localizedDescription
                }
            }
        }
    }
}

struct SwimmerCoachView: View {
    @EnvironmentObject var session: UserSession
    @StateObject var vm = SwimmerCoachViewModel()

    func subscribeConfirmationDialog(coach: Profile) -> ConfirmationDialog {
        ConfirmationDialog(
            title: "Subscribing to a coach",
            message: "You are going to subcribe to \(coach.fullname).",
            primaryButton: "Subscribe",
            primaryAction: { vm.saveSelectedCoach(coach) }
        )
    }

    func unsubscribeConfirmationDialog(coach: Profile) -> ConfirmationDialog {
        ConfirmationDialog(
            title: "Unsubscribe from your coach",
            message: "You are going to unsubcribe from \(coach.fullname).",
            primaryButton: "Unsubscribe",
            primaryAction: { vm.saveSelectedCoach(nil) }
        )
    }

    func replaceConfirmationDialog(currentCoach: Profile, newCoach: Profile) -> ConfirmationDialog {
        ConfirmationDialog(
            title: "Replace your current coach",
            message: "You are going to unsubcribe from \(currentCoach.fullname) and subscribe to \(newCoach.fullname).",
            primaryButton: "Replace",
            primaryAction: { vm.saveSelectedCoach(newCoach) }
        )
    }

    var chosenCoachHeader: some View {
        Group {
            if let currentCoach = vm.currentCoach {
                HStack(alignment: .firstTextBaseline) {
                    Text("You have selected")
                    Text("\(currentCoach.fullname)")
                        .font(.title3)
                        .foregroundColor(Color.mint)
                    Button {
                        vm.confirmationDialogPresented = unsubscribeConfirmationDialog(coach: currentCoach)
                    } label: {
                        Image(systemName: "trash").foregroundColor(Color.red)
                    }
                }
            } else {
                Text("Choose a coach in the list")
            }
        }
    }

    var coachsList: some View {
        List(vm.coachs) { coach in
            UserCellView(profile: coach)
                .listRowBackground(coach == vm.currentCoach ? Color.mint.opacity(0.5) : Color(UIColor.secondarySystemGroupedBackground))
                .onTapGesture {
                    switch vm.currentCoach {
                    case .none:
                        vm.confirmationDialogPresented = subscribeConfirmationDialog(coach: coach)

                    case let .some(currentCoach) where currentCoach.userId != coach.userId:
                        vm.confirmationDialogPresented = replaceConfirmationDialog(currentCoach: currentCoach, newCoach: coach)

                    default:
                        ()
                    }
                }
        }
    }

    var body: some View {
        Group {
            switch vm.state {
            case .loading:
                ProgressView()
            case let .info(message):
                Text(message)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            case .normal:
                VStack {
                    chosenCoachHeader
                    coachsList
                }
            }
        }
        .task { await vm.loadCoachs(withSelected: session.coachId) }
//        .task { vm.listenCoach(initialSelectedCoachId: session.coachId) }
        .refreshable { await vm.loadCoachs(withSelected: session.coachId) }

        .actionSheet(item: $vm.confirmationDialogPresented) { dialog in
            dialog.actionSheet()
        }
        .alert(vm.alertContext) {}
        .navigationBarTitle("My coach")
    }
}

// struct SwimmerCoachView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            SwimmerCoachView()
//        }
//    }
// }
