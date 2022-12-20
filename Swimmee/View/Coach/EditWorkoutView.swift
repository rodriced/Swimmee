//
//  EditWorkoutView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import SwiftUI

struct EditWorkoutView: View {
    @Environment(\.presentationMode) private var presentationMode
    func dismiss() { presentationMode.wrappedValue.dismiss() }

    @Environment(\.verticalSizeClass) var verticalSizeClass

    @StateObject var viewModel: EditWorkoutViewModel

    @State var deleteConfirmationPresented = false
    @State var unsendAndSaveAsDraftConfirmationPresented = false
    @State var resendConfirmationPresented = false
    @State var saveAsDraftConfirmationPresented = false
    @State var sendConfirmationPresented = false

    @FocusState private var isTitleFocused: Bool

    init(workout: Workout) {
//        print("EditWorkoutView.init (titile = \(workout.title)")
        _viewModel = StateObject(wrappedValue: EditWorkoutViewModel(workout: workout))
    }

    // MARK: - Date and Duration Pickers

    var datePicker: some View {
        DatePicker(selection: $viewModel.workout.date, displayedComponents: .date) {
            HStack {
                Image(systemName: "calendar")
                Text("Planned date")
            }
            .foregroundColor(Color.secondary)
        }
    }
    
    static let durationPickerData: [(Int, String)] =
        stride(from: 15, to: 241, by: 15).map { totalInMinutes in

            let hours = totalInMinutes / 60
            let minutes = totalInMinutes % 60
            let formatedMinutes = minutes < 10 ? "0\(minutes)" : "\(minutes)"

            return (totalInMinutes, "\(hours)h\(formatedMinutes)")
        }

    var durationPicker: some View {
        Picker(selection: $viewModel.workout.duration) {
            ForEach(Self.durationPickerData, id: \.0) { totalInMinutes, label in
                Text(label).tag(totalInMinutes)
            }
        } label: {
            HStack {
                Image(systemName: "timer")
                Text("Duration")
            }
            .foregroundColor(Color.secondary)
        }
    }

    // MARK: - Bottom buttons

    var bottomButtonsBar: some View {
        func doIfFormValidated(action: () -> Void) {
            guard viewModel.validateTitle() else {
                viewModel.alertContext.message = "Put something in title and retry."
                isTitleFocused = true
                return
            }

            action()
        }

        let config = viewModel.workout.isSent ?
            (saveAsDraft: (
                buttonLabel: "Unsend and save as draft",
                confirmationTitle: "Unsend and save as draft ?",
                confirmationPresented: $unsendAndSaveAsDraftConfirmationPresented,
                confirmationButton: { Button("Confirm Save as draft") {
                    viewModel.saveWorkout(andSendIt: false, completion: dismiss)
                }}
            ),
            sendButton: (
                buttonLabel: "Replace (Re-send)",
                confirmationTitle: "Replace sent workout ?",
                confirmationPresented: $resendConfirmationPresented,
                confirmationButton: { Button("Confirm Replace") {
                    viewModel.saveWorkout(andSendIt: true, completion: dismiss)
                }}
            ))
            :
            (saveAsDraft: (
                buttonLabel: "Save as draft",
                confirmationTitle: "Save as draft ?",
                confirmationPresented: $saveAsDraftConfirmationPresented,
                confirmationButton: { Button("Confirm Save as draft") {
                    viewModel.saveWorkout(andSendIt: false, completion: dismiss)
                }}
            ),
            sendButton: (
                buttonLabel: "Send",
                confirmationTitle: "Send workout ?",
                confirmationPresented: $sendConfirmationPresented,
                confirmationButton: { Button("Confirm Send") {
                    viewModel.saveWorkout(andSendIt: true, completion: dismiss)
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
            .disabled(!viewModel.canTryToSaveAsDraft)
            .confirmationDialog(config.saveAsDraft.confirmationTitle, isPresented: config.saveAsDraft.confirmationPresented, actions: config.saveAsDraft.confirmationButton)

            Button {
                config.sendButton.confirmationPresented.wrappedValue = true
            } label: {
                Text(config.sendButton.buttonLabel)
                    .frame(maxWidth: .infinity)
            }
            .disabled(!viewModel.canTryToSend)
            .confirmationDialog(config.sendButton.confirmationTitle, isPresented: config.sendButton.confirmationPresented, actions: config.sendButton.confirmationButton)
        }
        .buttonStyle(.borderedProminent)
    }

    // MARK: - Layout organization

    var formPart1: some View {
        Group {
            Section {
                TextField("Title", text: $viewModel.workout.title)
                    .focused($isTitleFocused)
            }

            datePicker
            durationPicker
        }
    }

    var formPart2: some View {
        TextEditorWithPlaceholder(text: $viewModel.workout.content, placeholder: "Workout details...", height: 400)
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
            if viewModel.workout.isSent {
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
        .navigationBarTitle(viewModel.originalWorkout.isNew ? "Create workout" : "Edit workout", displayMode: .inline)
        .navigationBarBackButtonHidden()

        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    deleteConfirmationPresented = true
                } label: {
                    Image(systemName: "trash").foregroundColor(Color.red)
                }
                .confirmationDialog("Delete workout ?", isPresented: $deleteConfirmationPresented) {
                    Button("Delete workout ?") { viewModel.deleteWorkout(completion: dismiss) }
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }

        .alert(viewModel.alertContext) {}
    }
}

struct EditWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditWorkoutView(workout: Workout.sample)
        }
    }
}
