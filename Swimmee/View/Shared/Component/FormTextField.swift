//
//  FormHelpers.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 25/10/2022.
//

import SwiftUI

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
