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
    @Published var chosenCoach: Profile?

    @Published var errorAlertDisplayed = false {
        didSet { if !errorAlertDisplayed { errorAlertMessage = "" } }
    }

    @Published var errorAlertMessage: String = "" {
        didSet { if !errorAlertMessage.isEmpty { errorAlertDisplayed = true } }
    }

    @MainActor
    func loadCoachs() async {
        do {
            print("load coachs")
            coachs = try await API.shared.profile.loadCoachs()
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

    func saveChosenCoach(for userId: String) {
        Task {
            do {
                try await API.shared.profile.updateCoach(for: userId, with: chosenCoach?.userId)
            } catch {
                await MainActor.run {
                    errorAlertMessage = error.localizedDescription
                }
            }
        }
    }
//    @Published var chosenCoach: Profile?
}

struct SwimmerCoachView: View {
    @StateObject var vm = SwimmerCoachViewModel()

    var body: some View {
        VStack {
            if let chosenCoach = vm.chosenCoach {
                HStack(alignment: .firstTextBaseline) {
                    Text("You have chosen")
                    Text("\(chosenCoach.fullname)").font(.title3).foregroundColor(Color.mint)
                    Button(action: { vm.chosenCoach = nil }) {
                        Image(systemName: "trash").foregroundColor(Color.red)
                    }
                }
            } else {
                Text("Choose a coach in the list")
            }
//            List
            List(vm.coachs) { coach in
                HStack(spacing: 20) {
                    Image("ProfilePhoto").resizable().frame(width: 60, height: 60).cornerRadius(8)
                    VStack(alignment: .leading, spacing: 5) {
                        Text("\(coach.fullname)").font(.title2)
                        Text("\(coach.email)").font(.callout)
                    }
                    //                .padding(EdgeInsets(leading:10 ))
                }
                .if(coach == vm.chosenCoach) {
                    $0.listRowBackground(Color.mint.opacity(0.5))
                }
                .onTapGesture {
                    vm.chosenCoach = coach
                }
            }
//            .task { await vm.loadCoachs() }
            .onReceive(vm.coachsPublisher()) { result in
                switch result {
                case .success(let coachs):
                    vm.coachs = coachs
                case .failure(let error):
                    vm.errorAlertMessage = error.localizedDescription
                }
            }
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