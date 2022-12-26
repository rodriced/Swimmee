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
        self.initialProfile = profile
        _userInfos = StateObject(wrappedValue: UserInfos(profile: profile))
    }

    var body: some View {
        Group {
            switch userInfos.userType {
            case .coach:
                CoachMainView()
                
            case .swimmer:
                SwimmerMainView(profile: initialProfile)
            }
        }
        .environmentObject(userInfos)
    }
}

