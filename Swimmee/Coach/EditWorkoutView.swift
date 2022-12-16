//
//  EditWorkoutView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import SwiftUI

@MainActor
class EditWorkoutViewModel: ObservableObject {
//    @Published var workout: Workout = .empty
    let workoutAPI: UserWorkoutCollectionAPI
    let originalWorkout: Workout
    @Published var workout: Workout

    func validateTitle() -> Bool {
        !workout.title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var canSend: Bool {
        !workout.isSent || (workout.isSent && workout.hasTextDifferent(from: originalWorkout))
    }

    var canSaveAsDraft: Bool {
        workout.isSent || (!workout.isSent && workout.hasTextDifferent(from: originalWorkout))
    }

    @Published var alertContext = AlertContext()

    init(workout: Workout, workoutAPI: UserWorkoutCollectionAPI = API.shared.workout) {
//        print("EditWorkoutViewModel.init (workout)")
        self.originalWorkout = workout
        self.workout = workout
        self.workoutAPI = workoutAPI
    }

    func saveWorkout(andSendIt: Bool, completion: (() -> Void)?) {
        var workoutToSave = workout // Working on a copy prevent reactive behaviours of the original workout on UI
        workoutToSave.isSent = andSendIt

        Task {
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
//    @StateObject var vm = EditWorkoutViewModel()
    @StateObject var vm: EditWorkoutViewModel
    @Environment(\.presentationMode) private var presentationMode

    @State private var confirmationDialogPresented: ConfirmationDialog?
    @FocusState private var isTitleFocused: Bool

//    let workout: Workout

    init(workout: Workout) {
//        print("EditWorkoutView.init (titile = \(workout.title)")
//        self.workout = workout
        _vm = StateObject(wrappedValue: EditWorkoutViewModel(workout: workout))
    }

    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }

    var sendConfirmationDialog: ConfirmationDialog {
        ConfirmationDialog(
            title: "Send workout ?",
            primaryButton: "Send",
            primaryAction: { vm.saveWorkout(andSendIt: true, completion: dismiss) }
        )
    }

    var resendConfirmationDialog: ConfirmationDialog {
        ConfirmationDialog(
            title: "Replace sent workout ?",
            primaryButton: "Replace",
            primaryAction: { vm.saveWorkout(andSendIt: true, completion: dismiss) }
        )
    }

    var unsendAndSaveAsDraftConfirmationDialog: ConfirmationDialog {
        ConfirmationDialog(
            title: "Unsend and save as draft ?",
            primaryButton: "Save as draft",
            primaryAction: { vm.saveWorkout(andSendIt: false, completion: dismiss) }
        )
    }

    var deleteConfirmationDialog: ConfirmationDialog {
        ConfirmationDialog(
            title: "Delete workout ?",
            primaryButton: "Delete",
            primaryAction: { vm.deleteWorkout(completion: dismiss) }
        )
    }

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
            (saveAsDraftButton: (
                label: "Unsend and save as draft",
                action: { doIfFormValidated { confirmationDialogPresented = unsendAndSaveAsDraftConfirmationDialog }}
            ),
            sendButton: (
                label: "Replace (Re-send)",
                action: { doIfFormValidated { confirmationDialogPresented = resendConfirmationDialog }}
            ))
            :
            (saveAsDraftButton: (
                label: "Save as draft",
                action: { doIfFormValidated { vm.saveWorkout(andSendIt: false, completion: dismiss) }}
            ),
            sendButton: (
                label: "Send",
                action: { doIfFormValidated { confirmationDialogPresented = sendConfirmationDialog }}
            ))

        return HStack {
            Button(action: config.saveAsDraftButton.action) {
                Text(config.saveAsDraftButton.label)
                    .frame(maxWidth: .infinity)
            }
            .foregroundColor(Color.black)
            .tint(Color.orange.opacity(0.7))
            .disabled(!vm.canSaveAsDraft)

            Button(action: config.sendButton.action) {
                Text(config.sendButton.label)
                    .frame(maxWidth: .infinity)
            }
            .disabled(!vm.canSend)
//            .keyboardShortcut(.defaultAction)
        }
        .buttonStyle(.borderedProminent)
    }

    var body: some View {
        VStack {
//            DebugHelper.viewBodyPrint("EditWorkoutView")
            if vm.workout.isSent {
                Label("Workout is published", systemImage: "exclamationmark.triangle")
                    .foregroundColor(.mint)
            }

            Form {
                Section {
                    TextField("Title", text: $vm.workout.title)
                        .focused($isTitleFocused)
                }
//                Section {
                DatePicker(selection: $vm.workout.date, displayedComponents: .date) {
//                    Text("Planned Date").foregroundColor(.secondary)
                    Label {
                        Text("Planned date")
                    } icon: {
                        Image(systemName: "calendar")
                    }
                    .foregroundColor(Color.secondary)
                }
//                }
//                Section {
                Picker(selection: $vm.workout.duration) {
//                        ForEach(stride(from: 15, to: 240, by: 15)) { minutes in
                    ForEach(1 ..< 17) { quarters in
                        let minutes = quarters * 15
                        Text("\(minutes / 60)h\(minutes % 60)")
                            .tag(minutes)
                    }
                } label: {
//                    Text("Duration").foregroundColor(.secondary)
                    Label {
                        Text("Duration")
                    } icon: {
                        Image(systemName: "timer")
                    }
                    .foregroundColor(Color.secondary)
                }

//                    DatePicker(selection: $vm.workout.duration, displayedComponents: .hourAndMinute) {
//                        Text("Duration")
                ////                        Label {
                ////                            Text("Duration")
                ////    //                        Text(vm.date, style: .date)
                ////                        } icon: {
                ////                            Image(systemName: "timer").foregroundColor(Color.mint)
                ////                        }
//                    }
//                }
                TextEditorWithPlaceholder(text: $vm.workout.content, placeholder: "Workout details...", height: 400)
            }

            bottomButtonsBar
                .padding()
        }
//        .onAppear { vm.workout = workout }

        .actionSheet(item: $confirmationDialogPresented) { dialog in
            dialog.actionSheet()
        }

        .navigationBarTitle(vm.originalWorkout.isNew ? "Create workout" : "Edit workout", displayMode: .inline)
        .navigationBarBackButtonHidden()

        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    confirmationDialogPresented = deleteConfirmationDialog
                } label: {
                    Image(systemName: "trash").foregroundColor(Color.red)
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
