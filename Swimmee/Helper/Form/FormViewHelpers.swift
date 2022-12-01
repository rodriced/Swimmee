//
//  FormHelpers.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 25/10/2022.
//

import SwiftUI

// MARK: View modifier roundedStyleWithErrorIndicator to stylize form text fields

struct RoundedStyleWithErrorIndicator: ViewModifier {
    var inError: Bool

    func body(content: Content) -> some View {
        content
            .textFieldStyle(.roundedBorder)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(inError ? Color.red : Color(UIColor.quaternarySystemFill), lineWidth: 0.5)
            )
    }
}

extension View {
    func roundedStyleWithErrorIndicator(inError: Bool) -> some View {
        modifier(RoundedStyleWithErrorIndicator(inError: inError))
    }
}

struct FormTextField: View {
    let title: String
    @Binding var value: String
    var inError: Bool

    var body: some View {
        TextField(title, text: $value)
            .disableAutocorrection(true)
            .roundedStyleWithErrorIndicator(inError: inError)
    }
}
