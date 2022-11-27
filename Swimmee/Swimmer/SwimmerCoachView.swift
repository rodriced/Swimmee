//
//  SwimmerCoachView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 11/10/2022.
//

import Combine
import SwiftUI

class SwimmerCoachViewModel: ObservableObject {
    @Published var coachs: [Profile] = []
    @Published var currentCoach: Profile?

    @Published var confirmationDialogPresented: ConfirmationDialog?

    @Published var errorAlertDisplayed = false {
        didSet { if !errorAlertDisplayed { errorAlertMessage = "" } }
    }

    @Published var errorAlertMessage: String = "" {
        didSet { if !errorAlertMessage.isEmpty { errorAlertDisplayed = true } }
    }

    @MainActor
    func loadCoachs(andSelect coachId: UserId?) async {
        do {
//            print("load coachs")
            coachs = try await API.shared.profile.loadCoachs()

            guard let coachId else {
                currentCoach = nil
                return
            }
            currentCoach = coachs.first { profile in
                profile.userId == coachId
            }
        } catch {
            errorAlertMessage = error.localizedDescription
        }
    }

// TODO: For live update. To test...
//    var cancellable: AnyCancellable?
//
//    func listenCoachs(initialSelectedCoachId: UserId?) {
//        cancellable = API.shared.profile.coachsPublisher()
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

    func saveSelectedCoach() {
        Task {
            do {
                try await API.shared.profile.updateCoach(with: currentCoach?.userId)
            } catch {
                await MainActor.run {
                    errorAlertMessage = error.localizedDescription
                }
            }
        }
    }

    func selectCoach(_ coach: Profile?) {
        currentCoach = coach
        saveSelectedCoach()
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
            primaryAction: { vm.selectCoach(coach) }
        )
    }

    func unsubscribeConfirmationDialog(coach: Profile) -> ConfirmationDialog {
        ConfirmationDialog(
            title: "Unsubscribe from your coach",
            message: "You are going to unsubcribe from \(coach.fullname).",
            primaryButton: "Unsubscribe",
            primaryAction: { vm.selectCoach(nil) }
        )
    }

    func replaceConfirmationDialog(currentCoach: Profile, newCoach: Profile) -> ConfirmationDialog {
        ConfirmationDialog(
            title: "Replace your current coach",
            message: "You are going to unsubcribe from \(currentCoach.fullname) and subscribe to \(newCoach.fullname).",
            primaryButton: "Replace",
            primaryAction: { vm.selectCoach(newCoach) }
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
            if vm.coachs.isEmpty {
                Text("No coach available for now.\nCome back later.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            } else {
                VStack {
                    chosenCoachHeader
                    coachsList
                }
            }
        }
        .task { await vm.loadCoachs(andSelect: session.coachId) }
//        .task { vm.listenCoach(initialSelectedCoachId: session.coachId) }

        .actionSheet(item: $vm.confirmationDialogPresented) { dialog in
            dialog.actionSheet()
        }
        .alert(vm.errorAlertMessage, isPresented: $vm.errorAlertDisplayed) {}
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
