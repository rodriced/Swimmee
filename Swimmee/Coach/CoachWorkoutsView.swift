//
//  CoachWorkoutsView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 09/10/2022.
//

import SwiftUI

class CoachWorkoutsViewModel: ObservableObject {
    @Published var items: [Workout] = [
        Workout(date: .now, duration: 90, title: "Workout #1", content: "Blabla\nBliblibli", isDraft: true),
        Workout(date: .now, duration: 90, title: "Workout #1", content: "Blabla\nBliblibli", isDraft: false),
        Workout(date: .now, duration: 90, title: "Workout #1", content: "Blabla\nBliblibli", isDraft: false)
    ]

    func removeItem(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
}

struct CoachWorkoutsView: View {
    @StateObject var vm = CoachWorkoutsViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach($vm.items) { $workout in

                    NavigationLink(destination: { EditWorkoutView(vm: EditWorkoutViewModel()) }) {
                        WorkoutView(workout: workout)
                    }
                    .listRowSeparator(.hidden)
                }
                .onDelete(perform: vm.removeItem)
            }
            .listStyle(.plain)
            .toolbar {
                NavigationLink {
                    EditWorkoutView(vm: EditWorkoutViewModel())
                } label: {
                    Image(systemName: "plus")
                }
            }
            .navigationBarTitle("Workouts", displayMode: .inline)
        }
        .navigationViewStyle(.stack)


//            VStack(spacing: 30) {
        ////                Text("You have 1 new message(s)")
//                ScrollView {
//                    VStack(spacing: 20) {
//                        ForEach($vm.items) { $workout in
//
//                            WorkoutView(workout: workout)
//
//                        }
//                        .onDelete(perform: vm.removeItem)
//                    }
//                }
//            }
//            .padding()
//        }
    }
}

struct CoachWorkoutsView_Previews: PreviewProvider {
    static var previews: some View {
        CoachWorkoutsView()
    }
}
