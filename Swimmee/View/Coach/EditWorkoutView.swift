//
//  EditWorkoutView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import SwiftUI

struct EditWorkoutView: View {
    @Environment(\.presentationMode) private var presentationMode
    private func dismiss() { presentationMode.wrappedValue.dismiss() }

    @Environment(\.verticalSizeClass) private var verticalSizeClass

    @StateObject private var viewModel: EditWorkoutViewModel

    @State private var deleteConfirmationPresented = false
    @FocusState private var isTitleFocused: Bool

    init(workout: Workout) {
        _viewModel = StateObject(wrappedValue: EditWorkoutViewModel(workout: workout))
    }

    // MARK: - Components
    
    // MARK: Date and Duration Pickers

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
    
    // MARK: Delete button
    
    var deleteButton: some View {
        Button {
            deleteConfirmationPresented = true
        } label: {
            Image(systemName: "trash").foregroundColor(Color.red)
        }
        .confirmationDialog("Delete workout ?", isPresented: $deleteConfirmationPresented) {
            Button("Delete workout ?") { viewModel.deleteWorkout(completion: dismiss) }
        }
    }

    // MARK: Bottom buttons

    struct SaveAsDraftButtonModifier: ViewModifier {
        func body(content: Content) -> some View {
            content.foregroundColor(Color.black)
                .tint(Color.orange.opacity(0.7))
        }
    }

    var unsentAndSaveAsDraftButton: some View {
        ButtonWithConfirmation(label: "Unpublish and save as draft",
                     isDisabled: !viewModel.canTryToSaveAsDraft,
                     confirmationTitle: "Unpublish and save as draft ?",
                     confirmationButtonLabel: "Confirm Save as draft",
                     buttonModifier: SaveAsDraftButtonModifier(),
                     action: {
                         viewModel.saveWorkout(andSendIt: false, onValidationError: { isTitleFocused = true })
                     })
    }

    var resendButton: some View {
        ButtonWithConfirmation(label: "Replace (Re-publish)",
                     isDisabled: !viewModel.canTryToSend,
                     confirmationTitle: "Replace already published workout ?",
                     confirmationButtonLabel: "Confirm Replace ?",
                     action: {
                         viewModel.saveWorkout(andSendIt: true, onValidationError: { isTitleFocused = true })
                     })
    }

    var saveAsDraftButton: some View {
        ButtonWithConfirmation(label: "Save as draft",
                     isDisabled: !viewModel.canTryToSaveAsDraft,
                     confirmationTitle: "Save as draft ?",
                     confirmationButtonLabel: "Confirm Save as draft",
                     buttonModifier: SaveAsDraftButtonModifier(),
                     action: {
                         viewModel.saveWorkout(andSendIt: false, onValidationError: { isTitleFocused = true })
                     })
    }

    var sendButton: some View {
        ButtonWithConfirmation(label: "Publish",
                     isDisabled: !viewModel.canTryToSend,
                     confirmationTitle: "Publish ?",
                     confirmationButtonLabel: "Publish workout ?",
                     action: {
                         viewModel.saveWorkout(andSendIt: true, onValidationError: { isTitleFocused = true })
                     })
    }

    var bottomButtonsBar: some View {
        HStack {
            if viewModel.workout.isSent {
                unsentAndSaveAsDraftButton
                resendButton
            } else {
                saveAsDraftButton
                sendButton
            }
        }
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
        .onTapGesture {
            hideKeyboard()
        }
        .navigationBarTitle(viewModel.originalWorkout.isNew ? "Create workout" : "Edit workout", displayMode: .inline)
        .navigationBarBackButtonHidden()

        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if !viewModel.originalWorkout.isNew {
                    deleteButton
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: dismiss)
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
