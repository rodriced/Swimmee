//
//  AuthView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 06/10/2022.
//

import SwiftUI

class UserSession: ObservableObject {
    @Published var profile: Profile

    init(profile: Profile) {
        self.profile = profile
    }
}

struct AuthView: View {
    //    @StateObject var session = UserSession()
    @StateObject var session: UserSession
    
    init(profile: Profile) {
        _session = StateObject(wrappedValue: UserSession(profile: profile))
    }

    var body: some View {
        switch session.profile.userType {
        case .coach:
            CoachMainView()
                .environmentObject(session)
        case .swimmer:
            SwimmerMainView()
                .environmentObject(session)
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView(profile: Profile(userType: .coach, firstName: "Max", lastName: "Lachaux", email: "m.l@ggmail.com"))
//            .environmentObject(UserSession())
    }
}
