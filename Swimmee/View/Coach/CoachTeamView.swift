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
    
    enum ViewState: Equatable {
        case loading
        case normal([Profile])
        case info(String)
    }
    
    @Published var state = ViewState.loading

    @MainActor
    func loadTeam() async {
        state = .loading
        
        do {
            let swimmers = try await profileAPI.loadTeam()
            
            guard !swimmers.isEmpty else {
                state = .info("No swimmers in your team for now.")
                return
            }
            
            state = .normal(swimmers)
            
        } catch {
            state = .info(error.localizedDescription)
        }
    }
}

struct CoachTeamView: View {
    @StateObject var viewModel = CoachTeamViewModel()

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()
            case let .info(message):
                Text(message)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            case let .normal(swimmers):
                List(swimmers) { swimmer in
                    UserCellView(profile: swimmer)
                }
            }
        }
        .task {
            await viewModel.loadTeam()
        }
        .refreshable {
            await viewModel.loadTeam()
        }
        .navigationBarTitle("My team")
    }
}

struct CoachTeamView_Previews: PreviewProvider {
    static var previews: some View {
        CoachTeamView()
    }
}
