//
//  TextEditorWithPlaceholder.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 16/11/2022.
//

import SwiftUI

struct TextEditorWithPlaceholder: View {
    @Binding var text: String
    var placeholder: String
    var height: CGFloat
    var isPlaceholderEnabled: Bool

    init(text: Binding<String>,
         placeholder: String = "Enter your text...",
         height: CGFloat,
         isPlaceholderEnabled: Bool = true
    ) {
        self._text = text
        self.placeholder = placeholder
        self.height = height
        self.isPlaceholderEnabled = isPlaceholderEnabled
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text).frame(height: height)

            if isPlaceholderEnabled && text.isEmpty {
                Text(placeholder).opacity(0.2).offset(y: 10)
            }
        }

    }
}

struct TextEditorWithPlaceholder_Previews: PreviewProvider {
    @State static var text: String = ""
    
    static var previews: some View {
        TextEditorWithPlaceholder(text: $text, height: 400)
    }
}
