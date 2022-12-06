//
//  WorkoutView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import SwiftUI

struct WorkoutView: View {
    let workout: Workout
    let isRead: Bool

    let typeColor: Color
    let typeText: String
    let icon: String

    init(workout: Workout, inReception: Bool, isRead: Bool = false) {
        self.workout = workout
        self.isRead = isRead

        (typeColor, typeText, icon) = {
            if inReception {
                return isRead ?
                    (.clear, "", "workout") : (.mint, "", "workout.fill")
            } else {
                return workout.isSent ?
                    (.mint, "sent", "arrow.up.workout.fill") : (.orange, "draft", "workout")
            }
        }()
    }

    var headerView: some View {
        HStack {
            Label {
                Text(workout.date, style: .date)
            } icon: {
                Image(systemName: "calendar")
            }
            Text(workout.date, style: .time).font(.caption)
            Spacer()
            Label {
                Text("\(workout.duration / 60)h\(workout.duration % 60)")
            } icon: {
                Image(systemName: "timer")
            }
        }
        .font(.headline)
//        .foregroundColor(typeColor)
    }

    var footerView: some View {
        HStack {
            if workout.isSent {
                EmptyView()
            } else {
                Text("draft").font(.headline).foregroundColor(Color.orange)
            }
            Spacer()
            Text(workout.title).font(.subheadline)
        }
    }

    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 15) {
            headerView
            Text(workout.content).font(.body)
            footerView
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .topBorder(color: typeColor)
        .cornerRadius(10)
    }
}

struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        let notSentWorkout = Workout.sample
        let sentWorkout: Workout = {
            var workout = Workout.sample
            workout.isSent = true
            return workout
        }()

        Group {
            WorkoutView(workout: notSentWorkout, inReception: false)
            WorkoutView(workout: sentWorkout, inReception: false)
            WorkoutView(workout: sentWorkout, inReception: true, isRead: false)
            WorkoutView(workout: sentWorkout, inReception: true, isRead: true)
        }
    }
}
