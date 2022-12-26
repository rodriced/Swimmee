//
//  MainView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 06/10/2022.
//

import SwiftUI

// Parent view of the application
// It manage the global states

struct MainView: View {
    @StateObject var session = Session()

    var body: some View {
        Group {
            switch session.state {
            case .undefined:
                ProgressView()
                
            case .signedOut:
                NavigationView {
                    SignUpView()
                }
                .navigationViewStyle(.stack)
                
            case .signedIn(let initialProfile):
                AuthenticatedMainView(profile: initialProfile)
                    .environmentObject(session)
                
            case .failure:
//                Text(error.localizedDescription)
                Color.clear
                
            case .deletingAccount:
                VStack {
                    Text("Deleting your account...")
                    ProgressView()
                }
                
            case .accountDeleted:
                VStack {
                    Text("Your account has been deleted").bold()
                    Text("")
                    Button("Go to Sign Up / Sign In", action: session.accountDeletionCompletion)
                }
            }
        }
        .task {
            session.startStateWorkflow()
        }
        .alert(session.stateFailureAlert) {
            Button("OK", action: session.abort)
        }
    }
}
