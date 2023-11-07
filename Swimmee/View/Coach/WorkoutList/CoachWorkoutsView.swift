//
//  CoachWorkoutsView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 09/10/2022.
//

import SwiftUI

struct CoachWorkoutsView: View {
    @EnvironmentObject var userInfos: UserInfos
    @EnvironmentObject var session: CoachSession
    
    @ObservedObject var viewModel: CoachWorkoutsViewModel

    init(viewModel: CoachWorkoutsViewModel) {
        _viewModel = ObservedObject(initialValue: viewModel)
    }

    // MARK: - Components

    var workoutsList: some View {
        Group {
            let filteredWorkouts = viewModel.filteredWorkouts
            if filteredWorkouts.isEmpty {
                Spacer()
                Text("No workouts found.")
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                List {
                    ForEach(filteredWorkouts) { workout in
                        NavigationLink(tag: workout, selection: $viewModel.selectedWorkout) {
                            EditWorkoutView(workout: workout)
                        } label: {
                            WorkoutView(workout: workout, inReception: false)
                        }
                        .listRowSeparator(.hidden)
                    }
                    .onDelete(perform: viewModel.deleteWorkout)
                }
                .listStyle(.plain)
            }
        }
    }

    var statusFilterIndication: some View {
        Group {
            if viewModel.statusFilterSelection != .all {
                (
                    Text(viewModel.statusFilterSelection.rawValue)
                        .foregroundColor(viewModel.statusFilterSelection == .draft ? .orange : .mint)
                        .bold()
                )
                .font(Font.system(.caption))
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

    var statusFilterMenu: some View {
        Menu {
            Picker("StatusFilter", selection: $viewModel.statusFilterSelection) {
                ForEach(CoachWorkoutsStatusFilter.allCases) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
//            .pickerStyle(.inline)
        } label: {
            Label("StatusFilter", systemImage: "slider.horizontal.3")
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

    var editNewWorkoutButton: some View {
        NavigationLink {
            EditWorkoutView(workout: Workout(userId: userInfos.userId))
        } label: {
            Image(systemName: "plus")
        }
    }

    var emptyListInformation: some View {
        VStack(spacing: 10) {
            Text("No workouts.")
            HStack {
                Text("Use")
                editNewWorkoutButton
                    .foregroundColor(.accentColor)
                    .shadow(radius: 5)
                Text("button to create one.")
            }
        }
        .foregroundColor(.secondary)
    }

    var body: some View {
        VStack(spacing: 30) {
            if viewModel.workouts.isEmpty {
                emptyListInformation
            } else {
                VStack {
                    if viewModel.isSomeFilterActivated {
                        HStack(spacing: 5) {
                            VStack {
                                statusFilterIndication
                                tagsFilterIndication
                            }
                            Button { viewModel.clearFilters() } label: { Image(systemName: "xmark.circle.fill") }
                        }
                        .padding(4)
                        .border(Color.secondary, width: 1)
                    }
                    workoutsList
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if !viewModel.workouts.isEmpty {
                    tagsFilterMenu
                    statusFilterMenu
                }

                editNewWorkoutButton
            }
        }
        .actionSheet(isPresented: $viewModel.sentWorkoutEditionConfirmationDialogPresented) {
            ActionSheet(
                title: Text("Edit an already sent workout ?"),
                message: Text("Workout will stay sent until you save it as draft or delete it."),
                buttons: [
                    .default(Text("Edit"), action: {
                        viewModel.navigatingToEditView = true
                    }),
                    .cancel()
                ]
            )
        }
        .alert(viewModel.alertContext) {}
        .navigationBarTitle("Workouts", displayMode: .inline)
    }
}

struct CoachWorkoutsView_Previews: PreviewProvider {
    static var previews: some View {
        CoachWorkoutsView(viewModel: CoachWorkoutsViewModel(initialData: Workout.sample.toSamples(5)))
            .environmentObject(UserInfos(profile: Profile.coachSample))
            .environmentObject(CoachSession())
    }
}
