//
//  SwimmerWorkoutsView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 09/10/2022.
//

import SwiftUI

struct SwimmerWorkoutsView: View {
    @EnvironmentObject var session: SwimmerSession
    @EnvironmentObject var router: UserRouter

    @ObservedObject var viewModel: SwimmerWorkoutsViewModel

    init(_ viewModel: SwimmerWorkoutsViewModel) {
        _viewModel = ObservedObject(initialValue: viewModel)
    }

    var newWorkoutsCountInfo: String {
        let plural = viewModel.newWorkoutsCount > 1 ? "s" : ""
        return "You have \(viewModel.newWorkoutsCount) new workout\(plural)"
    }

    var workoutsList: some View {
        Group {
            let filteredWorkoutsParams = viewModel.filteredWorkoutsParams
            if filteredWorkoutsParams.isEmpty {
                Spacer()
                Text("No workouts found.")
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                List(filteredWorkoutsParams, id: \.0.id) { workout, isRead in
                    WorkoutView(workout: workout, inReception: true, isRead: isRead)
                        .listRowSeparator(.hidden)
                        .onTapGesture {
                            viewModel.setWorkoutAsRead(workout)
                        }
                }
                .refreshable { viewModel.restartLoader?() }
                .listStyle(.plain)
            }
        }
    }

    var tagsFilterIndication: some View {
        Group {
            if let tagsIndexSelected = viewModel.tagFilterSelection {
                (
                    Text("Tags : ")
                        .foregroundColor(.secondary)
                        + Text(Workout.allTags[tagsIndexSelected])
//                        .foregroundColor(.brown)
                        .bold()
                )
                .font(Font.system(.caption))
            }
        }
    }

    var tagsFilterMenu: some View {
        Menu {
            Picker("TagsFilter", selection: $viewModel.tagFilterSelection) {
                Text("All").tag(nil as Int?)
                ForEach(Array(zip(Workout.allTags.indices, Workout.allTags)), id: \.0) { index, tag in
                    Text(tag).tag(index as Int?)
                }
            }
//            .pickerStyle(.inline)
        } label: {
            Label("TagsFilter", systemImage: "tag")
        }
    }

    var body: some View {
        VStack(spacing: 30) {
            if viewModel.workoutsParams.isEmpty {
                if session.coachId == nil {
                    VStack {
                        Text("Your coach will publish some workouts here.\nBut you haven't selcted one.\n")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        Button {
                            router.routeTo(setting: .coachSelection)
                        } label: {
                            Text("You can do it in settings ")
                            + Text(Image(systemName: "arrow.forward"))
                        }
                    }
                } else {
                    Text("No workouts from your coach for now.")
                        .foregroundColor(.secondary)
                }

            } else {
                VStack {
                    if viewModel.isSomeFilterActivated {
                        HStack(spacing: 5) {
                            VStack {
                                tagsFilterIndication
                            }
                            Button { viewModel.clearFilters() } label: { Image(systemName: "xmark.circle.fill") }
                        }
                        .padding(4)
                        .border(Color.secondary, width: 1)
                    } else if viewModel.newWorkoutsCount > 0 {
                        Text(newWorkoutsCountInfo)
                    }
                    workoutsList
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if !viewModel.workoutsParams.isEmpty {
                    tagsFilterMenu
                }
            }
        }
        .navigationBarTitle("Workouts", displayMode: .inline)
    }
}

 struct SwimmerWorkoutsView_Previews: PreviewProvider {
     static let workouts: [Workout] = {
         var workout = Workout.sample
         workout.dbId = "DbId"
         return workout.toSamples(5)
     }()

     static var previews: some View {
         SwimmerWorkoutsView(SwimmerWorkoutsViewModel(initialData:
             (workouts, Set((1 ... 2).map { workouts[$0].dbId! }))
         ))
         .environmentObject(UserInfos(profile: Profile.swimmerSample))
         .environmentObject(CoachSession())
     }
 }
