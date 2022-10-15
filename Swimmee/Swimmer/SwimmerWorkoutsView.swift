//
//  SwimmerWorkoutsView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 09/10/2022.
//

import SwiftUI

class SwimmerWorkoutsViewModel: ObservableObject {
    @Published var items: [Workout] = [
        Workout( date: .now, duration: 90, title: "Workout #1", content: "Blabla\nBliblibli", isDraft: true),
        Workout( date: .now, duration: 90, title: "Workout #1", content: "Blabla\nBliblibli", isDraft: false),
        Workout( date: .now, duration: 90, title: "Workout #1", content: "Blabla\nBliblibli", isDraft: false)
    ]
    
    func removeItem(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
}

struct SwimmerWorkoutsView: View {
    @StateObject var vm = SwimmerWorkoutsViewModel()

    var body: some View {
        NavigationView {
//            VStack(spacing: 30) {
//                Text("You have 1 new message(s)")
//                List {
//                    ForEach($vm.items) { $message in
//
//                        MessageView(message: message)
//                    }
//                    .onDelete(perform: vm.removeItem)
//                }
//
//            }

            VStack(spacing: 30) {
//                Text("You have 1 new message(s)")
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach($vm.items) { $workout in

                            WorkoutView(workout: workout)

                        }
                        .onDelete(perform: vm.removeItem)
                    }
                }
            }
            .padding()
            .navigationBarTitle("Workouts", displayMode: .inline)
        }
    }
}

struct SwimmerWorkoutsView_Previews: PreviewProvider {
    static var previews: some View {
        SwimmerWorkoutsView()
    }
}
