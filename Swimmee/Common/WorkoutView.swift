//
//  WorkoutView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import SwiftUI


struct WorkoutView: View {
    let workout: Workout
    let isHighlighted: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Label {
                    Text(workout.date, style: .date)
                    
                } icon: {
                    Image(systemName: "calendar")
                }
                Spacer()
                Label {

                Text("\(workout.duration / 60)h\(workout.duration % 60)")
                } icon: {
                    Image(systemName: "timer")
                }

            }.font(.headline)
            
            Text(workout.content).font(.body)
            HStack {
                if workout.isDraft {
                    Text("draft").font(.headline).foregroundColor(Color.orange)
                } else {
                    EmptyView()
                }
                Spacer()
                Text(workout.title).font(.subheadline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .if(workout.isDraft) { view in
            view.overlay(Rectangle().frame(maxWidth: .infinity, maxHeight: 5).foregroundColor(Color.orange), alignment: .top)
        }
        .cornerRadius(10)
    }
}

struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        let workout = Workout( date: .now, duration: 90, title: "Workout #1", content: "Blabla\nBliblibli", isDraft: true)

        WorkoutView(workout: workout)
    }
}
