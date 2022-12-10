//
//  UserSession.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 06/10/2022.
//

import Combine

class UserSession: ObservableObject {
    let profileAPI: ProfileCommonAPI
    let workoutAPI: UserWorkoutCollectionAPI
    let messageAPI: UserMessageCollectionAPI
    let userId: String
    let userType: UserType
    @Published var coachId: UserId?
    @Published var readWorkoutsIds: Set<Workout.DbId>
    @Published var readMessagesIds: Set<Message.DbId>
    
    var profileFuture: AnyPublisher<Profile,Error> { profileAPI.future(userId: nil) }

    lazy var allWorkoutsPublisher =
    workoutAPI.listPublisher(owner: .currentUser, isSent: nil)
            .share()

    lazy var workoutPublisher =
        $coachId
            .flatMap {
                coachId -> AnyPublisher<[Workout], Error> in
                self.workoutAPI.listPublisher(owner: .user(coachId ?? ""), isSent: true)
//                    .print("workout.listPublisher")
                    .eraseToAnyPublisher()
            }
//            .print("workoutPublisher")
            .multicast { CurrentValueSubject([]) }
            .autoconnect()

    lazy var readWorkoutsIdsPublisher =
        $readWorkoutsIds
            .setFailureType(to: Error.self)
//            .print("unreadWorkoutsPublisher")
            .multicast { CurrentValueSubject([]) }
            .autoconnect()

    lazy var unreadWorkoutsCountPublisher =
        workoutPublisher
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

    lazy var allMessagesPublisher =
    messageAPI.listPublisher(owner: .currentUser, isSent: nil)
            .share()

    lazy var messagePublisher =
        $coachId
            .flatMap {
                coachId -> AnyPublisher<[Message], Error> in
                self.messageAPI.listPublisher(owner: .user(coachId ?? ""), isSent: true)
//                    .print("message.listPublisher")
                    .eraseToAnyPublisher()
            }
//            .print("messagePublisher")
            .multicast { CurrentValueSubject([]) }
            .autoconnect()

    lazy var readMessagesIdsPublisher =
        $readMessagesIds
            .setFailureType(to: Error.self)
//            .print("unreadMessagesPublisher")
            .multicast { CurrentValueSubject([]) }
            .autoconnect()

    lazy var unreadMessagesCountPublisher =
        messagePublisher
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

    init(initialProfile: Profile,
         profileAPI: ProfileCommonAPI = API.shared.profile,
         workoutAPI: UserWorkoutCollectionAPI = API.shared.workout,
    messageAPI: UserMessageCollectionAPI = API.shared.message) {
        print("UserSession.init")

        self.userId = initialProfile.userId
        self.userType = initialProfile.userType
        self.coachId = initialProfile.coachId
        self.readWorkoutsIds = initialProfile.readWorkoutsIds ?? []
        self.readMessagesIds = initialProfile.readMessagesIds ?? []

        self.profileAPI = profileAPI
        self.workoutAPI = workoutAPI
        self.messageAPI = messageAPI
    }

    var cancellable: AnyCancellable?

    func listenChanges() {
        cancellable = profileAPI.publisher(userId: userId)
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

    var isCoach: Bool { userType == .coach }
    var isSwimmer: Bool { userType == .swimmer }
}
