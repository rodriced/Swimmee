//
//  SignedInView.swift
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

struct SignedInView: View {
   @EnvironmentObject var session: UserSession

    var body: some View {
        Group {
            switch session.profile.userType {
            case .coach:
                CoachMainView()
//                    .environmentObject(session)
//                    .environmentObject(userSession)
            case .swimmer:
                SwimmerMainView()
//                    .environmentObject(session)
            }
        }
        .onAppear {
            
        }
    }
    
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        
        let userSession = UserSession(profile: Profile(userType: .coach, firstName: "Max", lastName: "Lachaux", email: "m.l@ggmail.com"))

        SignedInView()
//            .environmentObject(session)
            .environmentObject(userSession)
    }
}
