//
//  MainView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 06/10/2022.
//

import SwiftUI

class Session: ObservableObject {
    @Published var userProfile: Profile?
    @Published var userTypeTest = UserType.coach
}

//class MainViewModel: ObservableObject {
//    @Published var isAuthenticated = false
//    @Published var userProfile: Profile?
//}

struct MainView: View {
//    @State var authenticated = false
//    @Environment(\.authenticated) var athenticated = false
//    @State var isAuthenticated = false
//    @State var authenticatedUserProfile: Profile?

    @StateObject var session = Session()

    var body: some View {
//        if let userProfile = session.userProfile {
        if session.userProfile != nil {
//            switch userProfile.userType {
            switch session.userTypeTest {
            case .coach:
                CoachMainView()
                    .environmentObject(session)
            case .swimmer:
                SwimmerMainView()
                    .environmentObject(session)
            }

        } else {
            SignUpView()
                .environmentObject(session)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
//            .environmentObject(Session())
    }
}
