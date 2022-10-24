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

    @Published var errorAlertIsPresenting = false {
        didSet {
            if errorAlertIsPresenting == false {
                errorAlertMessage = ""
            }
        }
    }

    var errorAlertMessage: String = "" {
        didSet {
            if !errorAlertMessage.isEmpty {
                errorAlertIsPresenting = true
            }
        }
    }

    func updateUser(userId: String?) {
        guard userProfile?.userId != userId else {
            // Nothing has changed
            debugPrint("updateUser: Nothing has changed")
            return
        }

        guard let userId = userId else {
            userProfile = nil
            debugPrint("updateUser: User was signed out")
            return
        }

        Task {
            do {
                debugPrint("updateUser: Loding profile \(userId)")
                let userProfile = try await Service.shared.store.loadProfile(userId: userId)
                debugPrint("updateUser: Loded profile -> \(String(describing: userProfile))")

                await MainActor.run {
                    guard userProfile != nil else {
                        errorAlertMessage = "No profile found. Can't sign in."
                        _ = Service.shared.auth.signOut()
                        return
                    }

                    self.userProfile = userProfile
                }
            } catch {
                await MainActor.run {
                    errorAlertMessage = error.localizedDescription
                }
            }
        }
    }
}

class UserSession: ObservableObject {
    @Published var profile: Profile

    init(profile: Profile) {
        self.profile = profile
    }
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
            }
        }
        .onReceive(Service.shared.auth.signedInStateChangePublisher()) { userId in
            print("Authenticathed : \(String(describing: userId))")
            session.updateUser(userId: userId)
        }
        .alert(session.errorAlertMessage, isPresented: $session.errorAlertIsPresenting) {}
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
