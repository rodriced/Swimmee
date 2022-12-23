//
//  FormHelpers.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 25/10/2022.
//

import SwiftUI

struct FormTextField: View {
    private let title: String
    @Binding private var text: String
    private var inError: Bool
    private var isSecure: Bool
    
    init(_ title: String, value: Binding<String>, inError: Bool, isSecure: Bool = false) {
        self.title = title
        self._text = value
        self.inError = inError
        self.isSecure = isSecure
    }

    var body: some View {
        if isSecure {
            SecureField(title, text: $text)
                .roundedStyleWithErrorIndicator(inError: inError)
        }
        else {
            TextField(title, text: $text)
                .disableAutocorrection(true)
                .roundedStyleWithErrorIndicator(inError: inError)
        }
    }
}

struct FormTextField_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            FormTextField("Title", value: Binding.constant(""), inError: false)
            FormTextField("Title", value: Binding.constant("Value"), inError: false)
            FormTextField("Title", value: Binding.constant("Value"), inError: true)
            FormTextField("Title", value: Binding.constant(""), inError: false, isSecure: true)
            FormTextField("Title", value: Binding.constant("Value"), inError: false, isSecure: true)
            FormTextField("Title", value: Binding.constant("Value"), inError: true, isSecure: true)
        }
    }
}
