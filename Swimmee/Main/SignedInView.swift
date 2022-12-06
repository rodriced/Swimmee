//
//  SignedInView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 06/10/2022.
//

import SwiftUI

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
