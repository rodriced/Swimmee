//
//  SwimmerWorkoutsViewModel.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 09/10/2022.
//

import Combine

class SwimmerWorkoutsViewModel: LoadableViewModel {

    // MARK: - Config

    struct Config: ViewModelConfig {
        let profileAPI: ProfileSwimmerAPI

        static var `default` = Config(profileAPI: API.shared.profile)
    }

    let config: Config

    //
    // MARK: - Properties
    //

    typealias LoadedData = ([Workout], Set<Workout.DbId>)
    typealias WorkoutsParams = [(workout: Workout, isRead: Bool)]

    @Published var workoutsParams: WorkoutsParams
    @Published var newWorkoutsCount: Int

    @Published var tagFilterSelection: Int? = nil

    var isSomeFilterActivated: Bool { tagFilterSelection != nil }

    var filteredWorkoutsParams: WorkoutsParams {
        workoutsParams.filter { workout, _ in
            tagFilterSelection.map { workout.tagsCache.contains($0) } ?? true
        }
    }

    //
    // MARK: - Protocol LoadableViewModel implementation
    //

    required init(initialData: LoadedData, config: Config = .default) {
        (workoutsParams, newWorkoutsCount) = Self.formatLoadedData(initialData)
        self.config = config
    }

    func refreshedLoadedData(_ loadedData: LoadedData) {
        (workoutsParams, newWorkoutsCount) = Self.formatLoadedData(loadedData)
    }

    var restartLoader: (() -> Void)?

    static func formatLoadedData(_ loadedData: LoadedData) -> (WorkoutsParams, Int) {
        var workouts = loadedData.0
        let readWorkoutsIds = loadedData.1

        Workout.updateTagsCache(for: &workouts)

        let workoutsParams =
            workouts.map { workout in
                (workout: workout,
                 isRead: workout.dbId.map { readWorkoutsIds.contains($0) } ?? false)
            }
        let newWorkoutsCount = workoutsParams.filter { !$0.isRead }.count

        return (workoutsParams, newWorkoutsCount)
    }

    //
    // MARK: - Actions
    //

    func clearFilters() {
        tagFilterSelection = nil
    }

    func setWorkoutAsRead(_ workout: Workout) {
        guard let dbId = workout.dbId else { return }
        Task {
            try? await config.profileAPI.setWorkoutAsRead(dbId)
        }
    }
}
