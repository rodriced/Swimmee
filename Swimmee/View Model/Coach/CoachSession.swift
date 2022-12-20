//
//  CoachSession.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 06/10/2022.
//

import Combine

class CoachSession: ObservableObject {
    let workoutAPI: UserWorkoutCollectionAPI
    let messageAPI: UserMessageCollectionAPI

    init(workoutAPI: UserWorkoutCollectionAPI = API.shared.workout,
         messageAPI: UserMessageCollectionAPI = API.shared.message)
    {
        print("CoachSession.init")

        self.workoutAPI = workoutAPI
        self.messageAPI = messageAPI
    }

    lazy var workoutsPublisher =
        workoutAPI.listPublisher(owner: .currentUser, isSent: nil)
            .share()

    lazy var messagesPublisher =
        messageAPI.listPublisher(owner: .currentUser, isSent: nil)
            .share()
}
