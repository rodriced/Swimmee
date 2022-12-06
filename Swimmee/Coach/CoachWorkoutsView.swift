//
//  CoachWorkoutsView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 09/10/2022.
//

import Combine
import SwiftUI

enum CoachWorkoutsFilter: String, CaseIterable, Identifiable {
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

    @Published var filter = CoachWorkoutsFilter.all

    var filteredWorkouts: [Workout] {
        workouts.filter { workout in
            filter == .all
                || (filter == .draft && !workout.isSent)
                || (filter == .sent && workout.isSent)
        }
    }

    @Published var selectedWorkout: Workout?
    @Published var confirmationDialogPresented = false
    @Published var navigatingToEditView = false

    @Published var alertContext = AlertContext()

    required init(initialData: [Workout], config: Config = .default) {
        print("CoachWorkoutsViewModel.init")
        workouts = initialData
        self.config = config
    }

    var restartLoader: (() -> Void)?

    func goEditingWorkout(_ workout: Workout) {
        selectedWorkout = workout

        if workout.isSent {
            confirmationDialogPresented = true
        } else {
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
    }
}

struct CoachWorkoutsView: View {
    @EnvironmentObject var session: UserSession
    @ObservedObject var vm: CoachWorkoutsViewModel
//    @StateObject var vm: CoachWorkoutsViewModel

    init(vm: CoachWorkoutsViewModel) {
        print("CoachWorkoutsView.init")
//        self._vm = StateObject(wrappedValue: vm)
        _vm = ObservedObject(initialValue: vm)
    }

    var workoutsList: some View {
//        if let selectedWorkout = vm.selectedWorkout {
//            NavigationLink(isActive: $vm.navigatingToEditView) {
//                EditWorkoutView(workout: selectedWorkout)
//            } label: {
//                EmptyView()
//            }
//        }

        List {
            ForEach(vm.filteredWorkouts) { workout in
                NavigationLink(tag: workout, selection: $vm.selectedWorkout) {
                    EditWorkoutView(workout: workout)
                } label: {
                    WorkoutView(workout: workout, inReception: session.isSwimmer)
                }
//                Button {
//                    vm.goEditingWorkout(workout)
//                } label: {
//                    HStack {
//                        WorkoutView(workout: workout, inReception: session.isSwimmer)
//                        Image(systemName: "chevron.forward")
//                            .font(Font.system(.footnote))
//                            .foregroundColor(Color.gray)
//                    }
//                }
                .listRowSeparator(.hidden)
            }
            .onDelete(perform: vm.deleteWorkout)
        }
        .listStyle(.plain)
    }

    var filterStateIndication: some View {
        Group {
            if vm.filter != .all {
                (
                    Text("Filter enabled : ")
                        .foregroundColor(.secondary)
                        + Text(vm.filter.rawValue)
                        .foregroundColor(vm.filter == .draft ? .orange : .mint)
                        .bold()
                )
                .font(Font.system(.caption))
            }
        }
    }

    var filterMenu: some View {
        Menu {
            Picker("Filter", selection: $vm.filter) {
                ForEach(CoachWorkoutsFilter.allCases) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
//            .pickerStyle(.inline)
        } label: {
            Label("Filter", systemImage: "slider.horizontal.3")
        }
    }

    var editNewWorkoutButton: some View {
        NavigationLink {
            EditWorkoutView(workout: Workout(userId: session.userId))
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
            DebugHelper.viewBodyPrint("CoachWorkoutsView.body")

            if vm.workouts.isEmpty {
                emptyListInformation
            } else {
                filterStateIndication
                workoutsList
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if !vm.workouts.isEmpty {
                    filterMenu
                }

                editNewWorkoutButton
            }
        }
        .actionSheet(isPresented: $vm.confirmationDialogPresented) {
            ActionSheet(
                title: Text("Edit an already sent workout ?"),
                message: Text("Workout will stay sent until you save it as draft or delete it."),
                buttons: [
                    .default(Text("Edit"), action: {
                        vm.navigatingToEditView = true
                    }),
                    .cancel()
                ]
            )
        }
        .alert(vm.alertContext) {}
        .navigationBarTitle("Workouts", displayMode: .inline)
    }
}

struct CoachWorkoutsView_Previews: PreviewProvider {
    static var previews: some View {
        CoachWorkoutsView(vm: CoachWorkoutsViewModel(initialData: [Workout.sample]))
            .environmentObject(UserSession(initialProfile: Profile.coachSample))
    }
}
