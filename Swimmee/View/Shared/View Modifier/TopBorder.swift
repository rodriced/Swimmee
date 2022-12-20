//
//  ViewHelpers.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import SwiftUI

struct TopBorder: ViewModifier {
    let color: Color
    let height: CGFloat

    func body(content: Content) -> some View {
        content
            .overlay(Rectangle()
                .frame(maxWidth: .infinity, maxHeight: height)
                .foregroundColor(color), alignment: .top)
    }
}

extension View {
    func topBorder(color: Color, height: CGFloat = 5) -> some View {
        modifier(TopBorder(color: color, height: height))
    }
}
