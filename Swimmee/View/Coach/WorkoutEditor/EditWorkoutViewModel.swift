//
//  EditWorkoutViewModel.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import Combine

@MainActor
class EditWorkoutViewModel: ObservableObject {

    // MARK: - Config

    let workoutAPI: UserWorkoutCollectionAPI

    //
    // MARK: - Properties
    //
    
    let originalWorkout: Workout
    @Published var workout: Workout

    @Published var alertContext = AlertContext()

    init(workout: Workout, workoutAPI: UserWorkoutCollectionAPI = API.shared.workout) {
        self.originalWorkout = workout
        self.workout = workout
        self.workoutAPI = workoutAPI
    }

    //
    // MARK: - Form validation
    //

    func validateTitle() -> Bool {
        !workout.title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var canTryToSend: Bool {
        !workout.isSent || (workout.isSent && workout.hasContentDifferent(from: originalWorkout))
    }

    var canTryToSaveAsDraft: Bool {
        workout.isSent || (!workout.isSent && workout.hasContentDifferent(from: originalWorkout))
    }

    //
    // MARK: - Actions
    //

//    @MainActor
    func saveWorkout(andSendIt: Bool, onValidationError: (() -> Void)? = nil, onSuccess: (() -> Void)? = nil) {
        guard validateTitle() else {
            alertContext.message = "Put something in title and retry."
            onValidationError?()
            return
        }

        Task {
            var workoutToSave = workout // Working on a copy prevent reactive behaviours of the original workout on UI
            workoutToSave.isSent = andSendIt

            var replaceAsNew = false

            switch (workout.isSent, andSendIt) {
            case (_, true):
                replaceAsNew = true
//                workoutToSave.date = .now
                  // TODO: needed a publication date
                
//            case (false, true):
//                workoutToSave.date = .now
            case (_, false):
                ()
            }

            do {
                _ = try await workoutAPI.save(workoutToSave, replaceAsNew: replaceAsNew)
                onSuccess?()
            } catch {
                alertContext.message = error.localizedDescription
            }
        }
    }

    func deleteWorkout(completion: (() -> Void)?) {
        guard let dbId = workout.dbId else {
            completion?()
            return
        }

        Task {
            do {
                try await workoutAPI.delete(id: dbId)
                completion?()
            } catch {
                alertContext.message = error.localizedDescription
            }
        }
    }
}
