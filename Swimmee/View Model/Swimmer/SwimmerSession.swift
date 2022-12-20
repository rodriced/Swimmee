//
//  SwimmerSession.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 06/10/2022.
//

import Combine

class SwimmerSession: ObservableObject {
    let profileAPI: ProfileCommonAPI
    let workoutAPI: UserWorkoutCollectionAPI
    let messageAPI: UserMessageCollectionAPI

    @Published var coachId: UserId?
    @Published var readWorkoutsIds: Set<Workout.DbId>
    @Published var readMessagesIds: Set<Message.DbId>

    var cancellable: AnyCancellable?

    init(initialProfile: Profile,
         profileAPI: ProfileCommonAPI = API.shared.profile,
         workoutAPI: UserWorkoutCollectionAPI = API.shared.workout,
         messageAPI: UserMessageCollectionAPI = API.shared.message)
    {
        print("SwimmerSession.init")

        self.profileAPI = profileAPI
        self.workoutAPI = workoutAPI
        self.messageAPI = messageAPI

        self.coachId = initialProfile.coachId
        self.readWorkoutsIds = initialProfile.readWorkoutsIds ?? []
        self.readMessagesIds = initialProfile.readMessagesIds ?? []
    }

    func listenChanges() {
        cancellable = profileAPI.publisher(userId: nil)
            .sink { _ in
            }
            receiveValue: { profile in
                if profile.coachId != self.coachId {
                    self.coachId = profile.coachId
                }
                self.readMessagesIds = profile.readMessagesIds ?? []
                self.readWorkoutsIds = profile.readWorkoutsIds ?? []
            }
    }

    lazy var workoutsPublisher =
        $coachId
            .flatMap {
                coachId -> AnyPublisher<[Workout], Error> in
                self.workoutAPI.listPublisher(owner: .user(coachId ?? ""), isSent: true)
//                    .print("workout.listPublisher")
                    .eraseToAnyPublisher()
            }
//            .print("swimmerWorkoutsPublisher")
            .multicast { CurrentValueSubject([]) }
            .autoconnect()

    lazy var readWorkoutsIdsPublisher =
        $readWorkoutsIds
            .setFailureType(to: Error.self)
//            .print("unreadWorkoutsPublisher")
            .multicast { CurrentValueSubject([]) }
            .autoconnect()

    lazy var unreadWorkoutsCountPublisher =
        workoutsPublisher
            .map { workouts in
                workouts.map(\.dbId)
            }
            .combineLatest(readWorkoutsIdsPublisher)
            .map { workoutsIds, readWorkoutsIds in
                Set(workoutsIds).subtracting(readWorkoutsIds).count
            }
            .removeDuplicates()
            .multicast { CurrentValueSubject(0) }
            .autoconnect()

    lazy var messagesPublisher =
        $coachId
            .flatMap {
                coachId -> AnyPublisher<[Message], Error> in
                self.messageAPI.listPublisher(owner: .user(coachId ?? ""), isSent: true)
//                    .print("message.listPublisher")
                    .eraseToAnyPublisher()
            }
//            .print("swimmerMessagesPublisher")
            .multicast { CurrentValueSubject([]) }
            .autoconnect()

    lazy var readMessagesIdsPublisher =
        $readMessagesIds
            .setFailureType(to: Error.self)
//            .print("unreadMessagesPublisher")
            .multicast { CurrentValueSubject([]) }
            .autoconnect()

    lazy var unreadMessagesCountPublisher =
        messagesPublisher
            .map { messages in
                messages.map(\.dbId)
            }
            .combineLatest(readMessagesIdsPublisher)
            .map { messagesIds, readMessagesIds in
                Set(messagesIds).subtracting(readMessagesIds).count
            }
            .removeDuplicates()
            .multicast { CurrentValueSubject(0) }
            .autoconnect()
}
