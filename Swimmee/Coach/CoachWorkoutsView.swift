//
//  CoachWorkoutsView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 09/10/2022.
//

import Combine
import SwiftUI

enum CoachWorkoutsStatusFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case draft = "Draft only"
    case sent = "Sent only"

    var id: Self { self }
}

class CoachWorkoutsViewModel: ObservableObject {
    struct Config: ViewModelConfig {
        let workoutAPI: UserWorkoutCollectionAPI

        static let `default` = Config(workoutAPI: API.shared.workout)
    }

    let config: Config

    @Published var workouts: [Workout]

    @Published var statusFilterSelection = CoachWorkoutsStatusFilter.all
    @Published var tagFilterSelection: Int? = nil

    var isSomeFilterActivated: Bool { statusFilterSelection != .all || tagFilterSelection != nil }

    var filteredWorkouts: [Workout] {
        workouts.filter { workout in
            (
                statusFilterSelection == .all
                    || (statusFilterSelection == .draft && !workout.isSent)
                    || (statusFilterSelection == .sent && workout.isSent)
            )
                &&
                tagFilterSelection.map { workout.tagsCache.contains($0) } ?? true
        }
    }

    @Published var selectedWorkout: Workout?
    @Published var sentWorkoutEditionConfirmationDialogPresented = false
    @Published var navigatingToEditView = false

    @Published var alertContext = AlertContext()

    required init(initialData: [Workout], config: Config = .default) {
//        print("CoachWorkoutsViewModel.init")

        self.workouts = initialData
        self.config = config
        
        Workout.updateTagsCache(for: &self.workouts)
    }

    var restartLoader: (() -> Void)?

    func clearFilters() {
        statusFilterSelection = .all
        tagFilterSelection = nil
    }

    func goEditingWorkout(_ workout: Workout) {
        selectedWorkout = workout

        if workout.isSent {
            sentWorkoutEditionConfirmationDialogPresented = true
            navigatingToEditView = false
        } else {
            sentWorkoutEditionConfirmationDialogPresented = false
            navigatingToEditView = true
        }
    }

    func deleteWorkout(at offsets: IndexSet) {
        guard let index = offsets.first else { return }

        let workoutToDelete = workouts[index]

        Task {
            do {
                if let dbId = workoutToDelete.dbId {
                    try await config.workoutAPI.delete(id: dbId)
                }
                workouts.remove(atOffsets: offsets)
            } catch {
                alertContext.message = error.localizedDescription
            }
        }
    }
}

extension CoachWorkoutsViewModel: LoadableViewModel {
    typealias LoadedData = [Workout]

    func refreshedLoadedData(_ loadedData: [Workout]) {
        workouts = loadedData
        Workout.updateTagsCache(for: &self.workouts)
    }
}

struct CoachWorkoutsView: View {
    @EnvironmentObject var userInfos: UserInfos
    @EnvironmentObject var session: CoachSession
    
    @ObservedObject var viewModel: CoachWorkoutsViewModel

    init(viewModel: CoachWorkoutsViewModel) {
//        print("CoachWorkoutsView.init")
        _viewModel = ObservedObject(initialValue: viewModel)
    }

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
//            DebugHelper.viewBodyPrint("CoachWorkoutsView.body")

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
        CoachWorkoutsView(viewModel: CoachWorkoutsViewModel(initialData: [Workout.sample]))
            .environmentObject(UserInfos(profile: Profile.coachSample))
            .environmentObject(CoachSession())
    }
}
