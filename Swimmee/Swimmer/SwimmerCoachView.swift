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
    @Published var selectedCoach: Profile?

    @Published var errorAlertDisplayed = false {
        didSet { if !errorAlertDisplayed { errorAlertMessage = "" } }
    }

    @Published var errorAlertMessage: String = "" {
        didSet { if !errorAlertMessage.isEmpty { errorAlertDisplayed = true } }
    }

    @MainActor
    func loadCoachs(andSelect coachId: UserId?) async {
        do {
            print("load coachs")
            coachs = try await API.shared.profile.loadCoachs()

            guard let coachId else {
                selectedCoach = nil
                return
            }
            selectedCoach = coachs.first { profile in
                profile.userId == coachId
            }
//                    editMode?.wrappedValue.isEditing = true
        } catch {
            errorAlertMessage = error.localizedDescription
        }
    }

    func coachsPublisher() -> AnyPublisher<Result<[Profile], Error>, Never> {
        API.shared.profile.coachsPublisher()
            .map { Result.success($0) }
            .catch { Just(Result.failure($0)) }
            .eraseToAnyPublisher()
    }

    func saveSelectedCoach() {
        Task {
            do {
                try await API.shared.profile.updateCoach(with: selectedCoach?.userId)
            } catch {
                await MainActor.run {
                    errorAlertMessage = error.localizedDescription
                }
            }
        }
    }

    func selectCoach(_ coach: Profile?) {
        selectedCoach = coach
        saveSelectedCoach()
    }
}

struct SwimmerCoachView: View {
    @EnvironmentObject var session: UserSession
    @StateObject var vm = SwimmerCoachViewModel()

    var body: some View {
        VStack {
            if let selectedCoach = vm.selectedCoach {
                HStack(alignment: .firstTextBaseline) {
                    Text("You have selected")
                    Text("\(selectedCoach.fullname)").font(.title3).foregroundColor(Color.mint)
                    Button(action: { vm.selectCoach(nil) }) {
                        Image(systemName: "trash").foregroundColor(Color.red)
                    }
                }
            } else {
                Text("Choose a coach in the list")
            }

            List(vm.coachs) { coach in
                UserCellView(profile: coach)
                    .if(coach == vm.selectedCoach) {
                        $0.listRowBackground(Color.mint.opacity(0.5))
                    }
                    .onTapGesture {
                        vm.selectCoach(coach)
                    }
            }
            .task { await vm.loadCoachs(andSelect: session.coachId) }
//            .onReceive(vm.coachsPublisher()) { result in
//                switch result {
//                case .success(let coachs):
//                    vm.coachs = coachs
//                case .failure(let error):
//                    vm.errorAlertMessage = error.localizedDescription
//                }
//            }
//            .toolbar() {
//                EditButton()
//            }
        }
        .navigationBarTitle("My coach")
        .alert(vm.errorAlertMessage, isPresented: $vm.errorAlertDisplayed) {}
    }
}

struct SwimmerCoachView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SwimmerCoachView()
        }
    }
}
