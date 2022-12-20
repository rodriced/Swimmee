//
//  MainView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 06/10/2022.
//

import SwiftUI

struct MainView: View {
    @StateObject var session = Session()

    var body: some View {
        Group {
            switch session.authenticationState {
            case .undefined:
                ProgressView()
            case .signedOut:
                NavigationView {
                    SignUpView()
                }
                .navigationViewStyle(.stack)
            case .signedIn(let initialProfile):
                AuthenticatedMainView(profile: initialProfile)
            case .failure:
//                Text(error.localizedDescription)
                Color.clear
            }
        }
        .onReceive(session.accountAPI.AuthenticationStatePublisher(), perform: session.updateAuthenticationState)
        .alert(session.authenticationFailureAlert) {
            Button("OK", action: session.errorAlertOkButtonCompletion)
        }
    }
}
