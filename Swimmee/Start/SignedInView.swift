//
//  SignedInView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 06/10/2022.
//

import Combine
import SwiftUI

class UserSession: ObservableObject {
    let userId: String
    let userType: UserType
    @Published var coachId: UserId?
    @Published var readMessagesIds: Set<Message.DbId> {
        didSet {
            print("readMessagesIds  = \(readMessagesIds.debugDescription)")
        }
    }

//    #if DEBUG
//        var debugCancellable: AnyCancellable?
//    #endif

    init(initialProfile: Profile) {
        print("UserSession.init")

        self.userId = initialProfile.userId
        self.userType = initialProfile.userType
        self.coachId = initialProfile.coachId
        self.readMessagesIds = initialProfile.readMessagesIds ?? []

        //        #if DEBUG
        //            debugCancellable = self.$coachId.sink { print("UserSession.$coachId receive \($0.debugDescription)") }
        //        #endif
    }

    var cancellable: AnyCancellable?

    func listenChanges() {
        cancellable = API.shared.profile.publisher(userId: userId)
            .sink { _ in
            }
            receiveValue: { profile in
                if profile.coachId != self.coachId {
                    self.coachId = profile.coachId
                }
                self.readMessagesIds = profile.readMessagesIds ?? []
            }
    }

    var isCoach: Bool { userType == .coach }
    var isSwimmer: Bool { userType == .swimmer }
}

struct SignedInView: View {
    @StateObject var session: UserSession

    init(profile: Profile) {
//        print("SignedInView.init")
        _session = StateObject(wrappedValue: UserSession(initialProfile: profile))
    }

    var body: some View {
        Group {
//            DebugHelper.viewBodyPrint("SignedInView")
            switch session.userType {
            case .coach:
                CoachMainView()
                    .environmentObject(session)
            case .swimmer:
                SwimmerMainView()
                    .environmentObject(session)
            }
        }
        .task {
            session.listenChanges()
        }
    }
}

struct SignedInView_Previews: PreviewProvider {
    static var previews: some View {
        SignedInView(profile: Profile.swimmerSample)
    }
}
