//
//  SwimmerWorkoutsView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 09/10/2022.
//

import SwiftUI

class SwimmerWorkoutsViewModel {
    struct Config: ViewModelConfig {
        let profileAPI: ProfileSwimmerAPI

        static var `default` = Config(profileAPI: API.shared.profile)
    }

    let config: Config

    typealias LoadedData = ([Workout], Set<Workout.DbId>)
    typealias WorkoutsParams = [(workout: Workout, isRead: Bool)]

    @Published var workoutsParams: WorkoutsParams
    @Published var newWorkoutsCount: Int

    @Published var tagFilterSelection: Int? = nil

    var isSomeFilterActivated: Bool { tagFilterSelection != nil }

    var filteredWorkoutsParams: WorkoutsParams {
        workoutsParams.filter { workout, _ in
            tagFilterSelection.map { workout.tagsCache.contains($0) } ?? true
        }
    }

    required init(initialData: LoadedData, config: Config = .default) {
//        print("SwimmerWorkoutsViewModel.init")
        (workoutsParams, newWorkoutsCount) = Self.formatLoadedData(initialData)
        self.config = config
    }

    static func formatLoadedData(_ loadedData: LoadedData) -> (WorkoutsParams, Int) {
        var workouts = loadedData.0
        let readWorkoutsIds = loadedData.1

        Workout.updateTagsCache(for: &workouts)

        let workoutsParams =
            workouts.map { workout in
                (workout: workout,
                 isRead: workout.dbId.map { readWorkoutsIds.contains($0) } ?? false)
            }
        let newWorkoutsCount = workoutsParams.filter { !$0.isRead }.count

        return (workoutsParams, newWorkoutsCount)
    }

    var restartLoader: (() -> Void)?

    func clearFilters() {
        tagFilterSelection = nil
    }

    func setWorkoutAsRead(_ workout: Workout) {
        guard let dbId = workout.dbId else { return }
        Task {
            try? await config.profileAPI.setWorkoutAsRead(dbId)
        }
    }
}

extension SwimmerWorkoutsViewModel: LoadableViewModel {
    func refreshedLoadedData(_ loadedData: LoadedData) {
        (workoutsParams, newWorkoutsCount) = Self.formatLoadedData(loadedData)
    }
}

struct SwimmerWorkoutsView: View {
    @EnvironmentObject var session: SwimmerSession
    @EnvironmentObject var router: UserRouter

    @ObservedObject var viewModel: SwimmerWorkoutsViewModel

    init(_ viewModel: SwimmerWorkoutsViewModel) {
//        print("SwimmerWorkoutsView.init")
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

// struct SwimmerWorkoutsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SwimmerWorkoutsView()
//    }
// }