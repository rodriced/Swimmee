//
//  MainView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 06/10/2022.
//

import FirebaseAuth
import SwiftUI

class Session: ObservableObject {
    @Published var userProfile: Profile?
}

struct MainView: View {

    @StateObject var session = Session()

    var body: some View {
        Group {
            if let userProfile = session.userProfile {
                SignedInView()
                    .environmentObject(UserSession(profile: userProfile))
            } else {
                SignUpView()
                    .environmentObject(session)
            }
        }
        .onReceive(Service.shared.auth.signedInStateChangePublisher()) { userProfile in
            session.userProfile = userProfile
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
