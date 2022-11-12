//
//  FormHelpers.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 25/10/2022.
//

import SwiftUI

struct RoundedStyleWithErrorIndicator: ViewModifier {
    var inError: Bool

    func body(content: Content) -> some View {
        content
            .textFieldStyle(.roundedBorder)
            .if(inError) {
                $0.overlay(RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.red, lineWidth: 1))
            }
    }
}

extension View {
    func roundedStyleWithErrorIndicator(inError: Bool) -> some View {
        modifier(RoundedStyleWithErrorIndicator(inError: inError))
    }
}
