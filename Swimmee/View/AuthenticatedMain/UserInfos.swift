//
//  UserInfos.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 06/10/2022.
//

import Combine

// UserInfos contains fixed user characteristics

class UserInfos: ObservableObject {
    let profileAPI: ProfileCommonAPI

    let userId: String
    let userType: UserType

    init(profile: Profile,
         profileAPI: ProfileCommonAPI = API.shared.profile)
    {
        self.profileAPI = profileAPI

        self.userId = profile.userId
        self.userType = profile.userType
    }

    var isSwimmer: Bool { userType == .swimmer }

    var profileFuture: AnyPublisher<Profile, Error> { profileAPI.future(userId: nil) }
}
