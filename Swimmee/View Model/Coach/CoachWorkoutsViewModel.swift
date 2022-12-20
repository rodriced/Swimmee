//
//  CoachWorkoutsViewModel.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 09/10/2022.
//

import Foundation
import Combine

enum CoachWorkoutsStatusFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case draft = "Draft only"
    case sent = "Sent only"

    var id: Self { self }
}

class CoachWorkoutsViewModel: ObservableObject {
    struct Config: ViewModelConfig {
        let workoutAPI: UserWorkoutCollectionAPI

        static let `default` = Config(workoutAPI: API.shared.workout)
    }

    let config: Config

    @Published var workouts: [Workout]

    @Published var statusFilterSelection = CoachWorkoutsStatusFilter.all
    @Published var tagFilterSelection: Int? = nil

    var isSomeFilterActivated: Bool { statusFilterSelection != .all || tagFilterSelection != nil }

    var filteredWorkouts: [Workout] {
        workouts.filter { workout in
            (
                statusFilterSelection == .all
                    || (statusFilterSelection == .draft && !workout.isSent)
                    || (statusFilterSelection == .sent && workout.isSent)
            )
                &&
                tagFilterSelection.map { workout.tagsCache.contains($0) } ?? true
        }
    }

    @Published var selectedWorkout: Workout?
    @Published var sentWorkoutEditionConfirmationDialogPresented = false
    @Published var navigatingToEditView = false

    @Published var alertContext = AlertContext()

    required init(initialData: [Workout], config: Config = .default) {
//        print("CoachWorkoutsViewModel.init")

        self.workouts = initialData
        self.config = config
        
        Workout.updateTagsCache(for: &self.workouts)
    }

    var restartLoader: (() -> Void)?

    func clearFilters() {
        statusFilterSelection = .all
        tagFilterSelection = nil
    }

    func goEditingWorkout(_ workout: Workout) {
        selectedWorkout = workout

        if workout.isSent {
            sentWorkoutEditionConfirmationDialogPresented = true
            navigatingToEditView = false
        } else {
            sentWorkoutEditionConfirmationDialogPresented = false
            navigatingToEditView = true
        }
    }

    func deleteWorkout(at offsets: IndexSet) {
        guard let index = offsets.first else { return }

        let workoutToDelete = workouts[index]

        Task {
            do {
                if let dbId = workoutToDelete.dbId {
                    try await config.workoutAPI.delete(id: dbId)
                }
                workouts.remove(atOffsets: offsets)
            } catch {
                alertContext.message = error.localizedDescription
            }
        }
    }
}

extension CoachWorkoutsViewModel: LoadableViewModel {
    typealias LoadedData = [Workout]

    func refreshedLoadedData(_ loadedData: [Workout]) {
        workouts = loadedData
        Workout.updateTagsCache(for: &self.workouts)
    }
}
