//
//  CoachTeamView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 11/10/2022.
//

import SwiftUI

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
