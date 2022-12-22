//
//  ButtonWithConfirmation.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 21/12/2022.
//

import SwiftUI

struct ButtonWithConfirmation<VM: ViewModifier>: View {
    let label: String
    let isDisabled: Bool
    let confirmationTitle: String
    let confirmationButtonLabel: String
    let buttonModifier: VM
    let action: () -> Void

    @State var confirmationIsPresented = false

    init(label: String = "Submit", isDisabled: Bool = false,
         confirmationTitle: String = "Confirmation",
         confirmationButtonLabel: String = "Confirm ?",
         buttonModifier: VM = EmptyModifier(),
         action: @escaping () -> Void)
    {
        self.label = label
        self.isDisabled = isDisabled
        self.confirmationTitle = confirmationTitle
        self.confirmationButtonLabel = confirmationButtonLabel
        self.buttonModifier = buttonModifier
        self.action = action
    }
    
    var body: some View {
        Button {
            confirmationIsPresented = true
        } label: {
            Text(label)
                .frame(maxWidth: .infinity)
        }
        .modifier(buttonModifier)
        .disabled(isDisabled)
        .buttonStyle(.borderedProminent)

        .confirmationDialog(confirmationTitle, isPresented: $confirmationIsPresented) {
            Button(confirmationButtonLabel, action: action)
        }
    }
}

struct SubmitButton_Previews: PreviewProvider {
    static var previews: some View {
        ButtonWithConfirmation(action: {})
    }
}
