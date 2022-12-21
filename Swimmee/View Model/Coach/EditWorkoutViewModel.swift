//
//  EditWorkoutViewModel.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import Combine

class EditWorkoutViewModel: ObservableObject {
    let workoutAPI: UserWorkoutCollectionAPI

    let originalWorkout: Workout
    @Published var workout: Workout

    @Published var alertContext = AlertContext()

    init(workout: Workout, workoutAPI: UserWorkoutCollectionAPI = API.shared.workout) {
//        print("EditWorkoutViewModel.init (workout)")
        self.originalWorkout = workout
        self.workout = workout
        self.workoutAPI = workoutAPI
    }

    func validateTitle() -> Bool {
        !workout.title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var canTryToSend: Bool {
        !workout.isSent || (workout.isSent && workout.hasTextDifferent(from: originalWorkout))
    }

    var canTryToSaveAsDraft: Bool {
        workout.isSent || (!workout.isSent && workout.hasTextDifferent(from: originalWorkout))
    }

    func saveWorkout(andSendIt: Bool, completion: (() -> Void)? = nil) {
        Task {
            var workoutToSave = workout // Working on a copy prevent reactive behaviours of the original workout on UI
            workoutToSave.isSent = andSendIt

            var replaceAsNew = false

            switch (workout.isSent, andSendIt) {
            case (_, true):
                replaceAsNew = true
                workoutToSave.date = .now
            // TODO: A draft workout sent for the first time should not be send as new workout because it has never been read by anyone (we track read workout with dbId and there is no reason here to generate a new one to set as unread for all swimmers)
//            case (false, true):
//                workoutToSave.date = .now
            case (_, false):
                ()
            }

            do {
                _ = try await workoutAPI.save(workoutToSave, replaceAsNew: replaceAsNew)
                completion?()
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
