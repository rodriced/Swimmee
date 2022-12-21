//
//  SwimmerCoachView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 11/10/2022.
//

import SwiftUI

struct SwimmerCoachView: View {
    @EnvironmentObject var session: SwimmerSession
    
    @StateObject var viewModel: SwimmerCoachViewModel

    init(viewModel: SwimmerCoachViewModel = SwimmerCoachViewModel()) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var chosenCoachHeader: some View {
        Group {
            if let currentCoach = viewModel.currentCoach {
                HStack(alignment: .firstTextBaseline) {
                    Text("You have selected")
                    Text("\(currentCoach.fullname)")
                        .font(.title3)
                        .foregroundColor(Color.mint)
                    Button {
                        viewModel.presentUnsubscribeConfirmation(coach: currentCoach)
                    } label: {
                        Image(systemName: "trash").foregroundColor(Color.red)
                    }
                }
            } else {
                Text("Choose a coach in the list")
            }
        }
    }

    var coachsList: some View {
        List(viewModel.coachs) { coach in
            UserCellView(profile: coach)
                .listRowBackground(coach == viewModel.currentCoach ? Color.mint.opacity(0.5) : Color(UIColor.secondarySystemGroupedBackground))
                .onTapGesture {
                    switch viewModel.currentCoach {
                    case .none:
                        viewModel.presentSubscribeConfirmation(coach: coach)

                    case let .some(currentCoach) where currentCoach.userId != coach.userId:
                        viewModel.presentReplaceConfirmation(currentCoach: currentCoach, newCoach: coach)

                    default:
                        ()
                    }
                }
        }
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()
            case let .info(message):
                Text(message)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            case .normal:
                VStack {
                    chosenCoachHeader
                    coachsList
                }
            }
        }
        .task { await viewModel.loadCoachs(withSelected: session.coachId) }
        .refreshable { await viewModel.loadCoachs(withSelected: session.coachId) }
        .confirmationDialog(viewModel.confirmation.title,
                            isPresented: $viewModel.confirmationPresented,
                            actions: viewModel.confirmation.button,
                            message: { Text(viewModel.confirmation.message) })

        .alert(viewModel.alertContext) {}
        .navigationBarTitle("My coach")
    }
}

 struct SwimmerCoachView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SwimmerCoachView()
                .environmentObject(SwimmerSession(initialProfile: Profile.swimmerSample))
        }
    }
 }
