//
//  CoachTeamView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 11/10/2022.
//

import SwiftUI

class CoachTeamViewModel: ObservableObject {
    let profileAPI: ProfileCoachAPI
    
    init(profileAPI: ProfileCoachAPI = API.shared.profile) {
        self.profileAPI = profileAPI
    }
    
    @Published var swimmers: [Profile] = Profile.swimmerSample.toSamples(with: 5)

    @Published var errorAlertDisplayed = false {
        didSet { if !errorAlertDisplayed { errorAlertMessage = "" } }
    }

    @Published var errorAlertMessage: String = "" {
        didSet { errorAlertDisplayed = !errorAlertMessage.isEmpty }
    }

    @MainActor
    func loadTeam() async {
        do {
            swimmers = try await profileAPI.loadTeam()
        } catch {
            swimmers = []
            errorAlertMessage = error.localizedDescription
        }
    }
}

struct CoachTeamView: View {
    @StateObject var vm = CoachTeamViewModel()

    var body: some View {
        List(vm.swimmers) { swimmer in
            UserCellView(profile: swimmer)
        }
        .task {
            await vm.loadTeam()
        }
        .refreshable {
            await vm.loadTeam()
        }
        .navigationBarTitle("My team")
        .alert(vm.errorAlertMessage, isPresented: $vm.errorAlertDisplayed) {}
    }
}

struct CoachTeamView_Previews: PreviewProvider {
    static var previews: some View {
        CoachTeamView()
    }
}
