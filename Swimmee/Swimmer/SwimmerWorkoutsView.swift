//
//  SwimmerWorkoutsView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 09/10/2022.
//

import SwiftUI

class SwimmerWorkoutsViewModel {
    struct Config: ViewModelConfig {
        let profileAPI: ProfileSwimmerAPI

        static var `default` = Config(profileAPI: API.shared.profile)
    }

    let config: Config

    typealias LoadedData = ([Workout], Set<Workout.DbId>)
    typealias WorkoutsParams = [(workout: Workout, isRead: Bool)]

    @Published var workoutsParams: [(workout: Workout, isRead: Bool)]
    @Published var newWorkoutsCount: Int

    required init(initialData: LoadedData, config: Config = .default) {
        print("SwimmerWorkoutsViewModel.init")
        (workoutsParams, newWorkoutsCount) = Self.formatLoadedData(initialData)
        self.config = config
    }

    static func formatLoadedData(_ loadedData: LoadedData) -> (WorkoutsParams, Int) {
        let (workouts, readWorkoutsIds) = loadedData

        let workoutsParams =
            workouts.map { workout in
                (workout: workout,
                 isRead: workout.dbId.map { readWorkoutsIds.contains($0) } ?? false)
            }
        let newWorkoutsCount = workoutsParams.filter { !$0.isRead }.count

        return (workoutsParams, newWorkoutsCount)
    }

    var restartLoader: (() -> Void)?

    func setWorkoutAsRead(_ workout: Workout) {
        guard let dbId = workout.dbId else { return }
        Task {
            try? await config.profileAPI.setWorkoutAsRead(dbId)
        }
    }
}

extension SwimmerWorkoutsViewModel: LoadableViewModel {
    func refreshedLoadedData(_ loadedData: LoadedData) {
        (workoutsParams, newWorkoutsCount) = Self.formatLoadedData(loadedData)
    }
}

struct SwimmerWorkoutsView: View {
    typealias ViewModel = SwimmerWorkoutsViewModel

    @EnvironmentObject var session: UserSession
    @ObservedObject var vm: SwimmerWorkoutsViewModel

    init(_ vm: SwimmerWorkoutsViewModel) {
        print("SwimmerWorkoutsView.init")
        _vm = ObservedObject(initialValue: vm)
    }

    var newWorkoutsCountInfo: String {
        let plural = vm.newWorkoutsCount > 1 ? "s" : ""
        return "You have \(vm.newWorkoutsCount) new workout\(plural)"
    }

    var workoutsList: some View {
        List(vm.workoutsParams, id: \.0.id) { workout, isRead in
            WorkoutView(workout: workout, inReception: session.isSwimmer, isRead: isRead)
                .listRowSeparator(.hidden)
                .onTapGesture {
                    vm.setWorkoutAsRead(workout)
                }
        }
        .refreshable { vm.restartLoader?() }
        .listStyle(.plain)
    }

    var body: some View {
        VStack(spacing: 30) {
            if vm.workoutsParams.isEmpty {
                Text(
                    session.coachId == nil ?
                        "Subscribe to a coach in the Settings menu\nto see his workouts."
                        : "No workouts from your coach for now."
                )
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            } else {
                if vm.newWorkoutsCount > 0 {
                    Text(newWorkoutsCountInfo)
                }
                workoutsList
            }
        }
        .navigationBarTitle("Workouts", displayMode: .inline)
    }
}

// struct SwimmerWorkoutsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SwimmerWorkoutsView()
//    }
// }
