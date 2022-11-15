//
//  ViewHelpers.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import Foundation
import SwiftUI

// MARK: Modifiers if and ifLet to apply modifier conditionnally

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, modify: (Self) -> Content) -> some View {
        if condition {
            modify(self)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func ifLet1<Content: View, T: Any>(_ optional: Optional<T>, modify: (Self, T) -> Content) -> some View {
        if let value = optional {
            modify(self, value)
        } else {
            self
        }
    }
}

// MARK: topBorder modifier

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
