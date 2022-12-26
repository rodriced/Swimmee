//
//  CoachTeamViewModel.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 11/10/2022.
//

import Combine

class CoachTeamViewModel: ObservableObject {
    
    // MARK: - Config

    let profileAPI: ProfileCoachAPI
    
    init(profileAPI: ProfileCoachAPI = API.shared.profile) {
        self.profileAPI = profileAPI
    }
    
    //
    // MARK: - Properties
    //
    
    enum ViewState: Equatable {
        case loading
        case normal([Profile])
        case info(String)
    }
    
    @Published var state = ViewState.loading

    //
    // MARK: - Actions
    //
    
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
