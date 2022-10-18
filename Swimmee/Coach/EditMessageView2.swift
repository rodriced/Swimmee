//
//  EditMessageView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import SwiftUI

struct EditMessageView2: View {
    @Binding var message: Message
    
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack {
            Form {
                Section {
                    TextField("Title", text: $message.title)
                }
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $message.content).frame(height: 400)
                    Text("Content").opacity(0.2)
                }
            }

            HStack {
                Button(action: {presentationMode.wrappedValue.dismiss()}) {
                    Text("Save as draft").frame(maxWidth: .infinity)
                }
                .foregroundColor(Color.black)
                .tint(Color.orange.opacity(0.7))

                Button(action: {presentationMode.wrappedValue.dismiss()}) {
                    Text("Send").frame(maxWidth: .infinity)
                }
                .keyboardShortcut(.defaultAction)
            }
            .buttonStyle(.borderedProminent)
            .padding()
            
        }
        .navigationTitle("Edit message")
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

struct EditMessageView2_Previews: PreviewProvider {
    @State static var message = Message.sample
    
    static var previews: some View {
        NavigationView {
            EditMessageView2(message: $message)
        }
    }
}
