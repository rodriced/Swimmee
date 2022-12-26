//
//  CoachSession.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 06/10/2022.
//

import Combine

// CoachSession provide workouts and messages publishers for live updates in the application coach's part

class CoachSession: ObservableObject {
    
    // MARK: - Config

    let workoutAPI: UserWorkoutCollectionAPI
    let messageAPI: UserMessageCollectionAPI

    init(workoutAPI: UserWorkoutCollectionAPI = API.shared.workout,
         messageAPI: UserMessageCollectionAPI = API.shared.message)
    {
        self.workoutAPI = workoutAPI
        self.messageAPI = messageAPI
    }

    // MARK: - Publishers

    lazy var workoutsPublisher =
        workoutAPI.listPublisher(owner: .currentUser, isSent: nil)
            .share()

    lazy var messagesPublisher =
        messageAPI.listPublisher(owner: .currentUser, isSent: nil)
            .share()
}
