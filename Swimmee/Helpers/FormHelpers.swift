//
//  FormHelpers.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 25/10/2022.
//

import SwiftUI

struct WithErrorIndicator: ViewModifier {
    var inError: Binding<Bool>

    func body(content: Content) -> some View {
        content
            .textFieldStyle(.roundedBorder)
            .if(inError.wrappedValue) {
                $0.overlay(RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.red, lineWidth: 1))
            }
    }
}

