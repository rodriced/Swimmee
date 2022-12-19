//
//  EditWorkoutView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import SwiftUI

class EditWorkoutViewModel: ObservableObject {
    let workoutAPI: UserWorkoutCollectionAPI

    let originalWorkout: Workout
    @Published var workout: Workout

    @Published var alertContext = AlertContext()

    init(workout: Workout, workoutAPI: UserWorkoutCollectionAPI = API.shared.workout) {
//        print("EditWorkoutViewModel.init (workout)")
        self.originalWorkout = workout
        self.workout = workout
        self.workoutAPI = workoutAPI
    }

    func validateTitle() -> Bool {
        !workout.title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var canTryToSend: Bool {
        !workout.isSent || (workout.isSent && workout.hasTextDifferent(from: originalWorkout))
    }

    var canTryToSaveAsDraft: Bool {
        workout.isSent || (!workout.isSent && workout.hasTextDifferent(from: originalWorkout))
    }

    func saveWorkout(andSendIt: Bool, completion: (() -> Void)?) {
        Task {
            var workoutToSave = workout // Working on a copy prevent reactive behaviours of the original workout on UI
            workoutToSave.isSent = andSendIt

            var replaceAsNew = false

            switch (workout.isSent, andSendIt) {
            case (_, true):
                replaceAsNew = true
                workoutToSave.date = .now
            // TODO: A draft workout sent for the first time should not be send as new workout because it has never been read by anyone (we track read workout with dbId and there is no reason here to generate a new one to set as unread for all swimmers)
//            case (false, true):
//                workoutToSave.date = .now
            case (_, false):
                ()
            }

            do {
                _ = try await workoutAPI.save(workoutToSave, replaceAsNew: replaceAsNew)
                completion?()
            } catch {
                alertContext.message = error.localizedDescription
            }
        }
    }

    func deleteWorkout(completion: (() -> Void)?) {
        guard let dbId = workout.dbId else {
            completion?()
            return
        }

        Task {
            do {
                try await workoutAPI.delete(id: dbId)
                completion?()
            } catch {
                alertContext.message = error.localizedDescription
            }
        }
    }
}

struct EditWorkoutView: View {
    @Environment(\.presentationMode) private var presentationMode
    func dismiss() { presentationMode.wrappedValue.dismiss() }

    @Environment(\.verticalSizeClass) var verticalSizeClass

    @StateObject var vm: EditWorkoutViewModel

    @State var deleteConfirmationPresented = false
    @State var unsendAndSaveAsDraftConfirmationPresented = false
    @State var resendConfirmationPresented = false
    @State var saveAsDraftConfirmationPresented = false
    @State var sendConfirmationPresented = false

    @FocusState private var isTitleFocused: Bool

    init(workout: Workout) {
//        print("EditWorkoutView.init (titile = \(workout.title)")
        _vm = StateObject(wrappedValue: EditWorkoutViewModel(workout: workout))
    }

    // MARK: Duration picker

    static let durationPickerData: [(Int, String)] =
        stride(from: 15, to: 241, by: 15).map { totalInMinutes in

            let hours = totalInMinutes / 60
            let minutes = totalInMinutes % 60
            let formatedMinutes = minutes < 10 ? "0\(minutes)" : "\(minutes)"

            return (totalInMinutes, "\(hours)h\(formatedMinutes)")
        }

    var durationPicker: some View {
        Picker(selection: $vm.workout.duration) {
            ForEach(Self.durationPickerData, id: \.0) { totalInMinutes, label in
                Text(label).tag(totalInMinutes)
            }
        } label: {
            Label {
                Text("Duration")
            } icon: {
                Image(systemName: "timer")
            }
            .foregroundColor(Color.secondary)
        }
    }

    // MARK: Bottom buttons

    var bottomButtonsBar: some View {
        func doIfFormValidated(action: () -> Void) {
            guard vm.validateTitle() else {
                vm.alertContext.message = "Put something in title and retry."
                isTitleFocused = true
                return
            }

            action()
        }

        let config = vm.workout.isSent ?
            (saveAsDraft: (
                buttonLabel: "Unsend and save as draft",
                confirmationTitle: "Unsend and save as draft ?",
                confirmationPresented: $unsendAndSaveAsDraftConfirmationPresented,
                confirmationButton: { Button("Confirm Save as draft") {
                    vm.saveWorkout(andSendIt: false, completion: dismiss)
                }}
            ),
            sendButton: (
                buttonLabel: "Replace (Re-send)",
                confirmationTitle: "Replace sent workout ?",
                confirmationPresented: $resendConfirmationPresented,
                confirmationButton: { Button("Confirm Replace") {
                    vm.saveWorkout(andSendIt: true, completion: dismiss)
                }}
            ))
            :
            (saveAsDraft: (
                buttonLabel: "Save as draft",
                confirmationTitle: "Save as draft ?",
                confirmationPresented: $saveAsDraftConfirmationPresented,
                confirmationButton: { Button("Confirm Save as draft") {
                    vm.saveWorkout(andSendIt: false, completion: dismiss)
                }}
            ),
            sendButton: (
                buttonLabel: "Send",
                confirmationTitle: "Send workout ?",
                confirmationPresented: $sendConfirmationPresented,
                confirmationButton: { Button("Confirm Send") {
                    vm.saveWorkout(andSendIt: true, completion: dismiss)
                }}
            ))

        return HStack {
            Button {
                config.saveAsDraft.confirmationPresented.wrappedValue = true
            } label: {
                Text(config.saveAsDraft.buttonLabel)
                    .frame(maxWidth: .infinity)
            }
            .foregroundColor(Color.black)
            .tint(Color.orange.opacity(0.7))
            .disabled(!vm.canTryToSaveAsDraft)
            .confirmationDialog(config.saveAsDraft.confirmationTitle, isPresented: config.saveAsDraft.confirmationPresented, actions: config.saveAsDraft.confirmationButton)

            Button {
                config.sendButton.confirmationPresented.wrappedValue = true
            } label: {
                Text(config.sendButton.buttonLabel)
                    .frame(maxWidth: .infinity)
            }
            .disabled(!vm.canTryToSend)
            .confirmationDialog(config.sendButton.confirmationTitle, isPresented: config.sendButton.confirmationPresented, actions: config.sendButton.confirmationButton)
        }
        .buttonStyle(.borderedProminent)
    }

    // MARK: Layout organization

    var formPart1: some View {
        Group {
            Section {
                TextField("Title", text: $vm.workout.title)
                    .focused($isTitleFocused)
            }

            DatePicker(selection: $vm.workout.date, displayedComponents: .date) {
                Label {
                    Text("Planned date")
                } icon: {
                    Image(systemName: "calendar")
                }
                .foregroundColor(Color.secondary)
            }

            durationPicker
        }
    }

    var formPart2: some View {
        TextEditorWithPlaceholder(text: $vm.workout.content, placeholder: "Workout details...", height: 400)
    }

    var portraitView: some View {
        Form {
            formPart1
            formPart2
        }
    }

    var landscapeView: some View {
        HStack(spacing: 10) {
            Form { formPart1 }
            Form { formPart2 }
        }
    }

    var body: some View {
        VStack {
//            DebugHelper.viewBodyPrint("EditWorkoutView")
            if vm.workout.isSent {
                Label("Workout is published", systemImage: "exclamationmark.triangle")
                    .foregroundColor(.mint)
            }

            if verticalSizeClass == .compact {
                landscapeView
            } else {
                portraitView
            }

            bottomButtonsBar
                .padding()
        }
        .navigationBarTitle(vm.originalWorkout.isNew ? "Create workout" : "Edit workout", displayMode: .inline)
        .navigationBarBackButtonHidden()

        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    deleteConfirmationPresented = true
                } label: {
                    Image(systemName: "trash").foregroundColor(Color.red)
                }
                .confirmationDialog("Delete workout ?", isPresented: $deleteConfirmationPresented) {
                    Button("Delete workout ?") { vm.deleteWorkout(completion: dismiss) }
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }

        .alert(vm.alertContext) {}
    }
}

struct EditWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditWorkoutView(workout: Workout.sample)
        }
    }
}
