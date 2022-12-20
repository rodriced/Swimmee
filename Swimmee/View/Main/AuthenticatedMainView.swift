//
//  AuthenticatedMainView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 06/10/2022.
//

import SwiftUI

struct AuthenticatedMainView: View {
    let initialProfile: Profile
    @StateObject var userInfos: UserInfos

    init(profile: Profile) {
//        print("AuthenticatedMainView.init")
        self.initialProfile = profile
        _userInfos = StateObject(wrappedValue: UserInfos(profile: profile))
    }

    var body: some View {
        Group {
//            DebugHelper.viewBodyPrint("AuthenticatedMainView")
            switch userInfos.userType {
            case .coach:
                CoachMainView()
//                    .environmentObject(session)
            case .swimmer:
                SwimmerMainView(profile: initialProfile)
//                    .environmentObject(session)
            }
        }
        .environmentObject(userInfos)
    }
}

struct SignedInView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticatedMainView(profile: Profile.swimmerSample)
    }
}
