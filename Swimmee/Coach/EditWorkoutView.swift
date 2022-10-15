//
//  EditWorkoutView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import SwiftUI

class EditWorkoutViewModel: ObservableObject {
    @Published var date: Date
    @Published var duration: Date
    @Published var title: String
    @Published var content: String

    init(date: Date = .now, duration: Date = .now, title: String = "", content: String = "") {
        self.date = date
        self.duration = duration
        self.title = title
        self.content = content
    }
}

struct EditWorkoutView: View {
    @ObservedObject var vm: EditWorkoutViewModel
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack {
            Form {
                Section {
                    TextField("Title", text: $vm.title)
                }
                Section {
                    DatePicker(selection: $vm.date) {
                        Text("Planned Date")
//                        Label {
//                            Text("Date")
//                        } icon: {
//                            Image(systemName: "calendar").foregroundColor(Color.mint)
//                        }
                    }
                    
                }
                Section {
                    DatePicker(selection: $vm.duration, displayedComponents: .hourAndMinute) {
                        Text("Duration")
//                        Label {
//                            Text("Duration")
//    //                        Text(vm.date, style: .date)
//                        } icon: {
//                            Image(systemName: "timer").foregroundColor(Color.mint)
//                        }
                    }
                }
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $vm.content).frame(height: 300)
                    Text("Enter workout details...").opacity(0.2)
                }
            }

            HStack {
                Button(action: {presentationMode.wrappedValue.dismiss()}) {
                    Text("Save as draft").frame(maxWidth: .infinity)
                }
                .foregroundColor(Color.black)
                .tint(Color.orange.opacity(0.7))

                Button(action: {presentationMode.wrappedValue.dismiss()}) {
                    Text("Publish").frame(maxWidth: .infinity)
                }
                .keyboardShortcut(.defaultAction)
            }
            .buttonStyle(.borderedProminent)
            .padding()
            
        }
        .navigationTitle("Edit workout")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {}) {
                    Image(systemName: "trash").foregroundColor(Color.red)
                }
            }
        }
//        }
    }
}

struct EditWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditWorkoutView(vm: EditWorkoutViewModel())
        }
    }
}
