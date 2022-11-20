//
//  SignedInView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 06/10/2022.
//

import SwiftUI
import Combine

class UserSession: ObservableObject {
    let userId: String
    let userType: UserType
    @Published var coachId: UserId?
//    {
//        didSet { print("UserSession.coachId updated to \(coachId.debugDescription)") }
//    }

//    #if DEBUG
//        var debugCancellable: AnyCancellable?
//    #endif
    init(userId: UserId, userType: UserType, coachId: UserId?) {
        print("UserSession.init")

        self.userId = userId
        self.userType = userType
        self.coachId = coachId

//        #if DEBUG
//            debugCancellable = self.$coachId.sink { print("UserSession.$coachId receive \($0.debugDescription)") }
//        #endif
    }

    convenience init(profile: Profile) {
        self.init(userId: profile.userId, userType: profile.userType, coachId: profile.coachId)
//        self.userId = profile.userId
//        self.userType = profile.userType
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
            }
    }

    var isCoach: Bool { userType == .coach }
    var isSwimmer: Bool { userType == .swimmer }
}

struct SignedInView: View {
    @StateObject var session: UserSession

    init(profile: Profile) {
//        print("SignedInView.init")
        _session = StateObject(wrappedValue: UserSession(profile: profile))
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
