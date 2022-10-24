//
//  ViewHelpers.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import Foundation
import SwiftUI

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
    func `ifLet1`<Content: View, T: Any>(_ optional: Optional<T>, modify: (Self, T) -> Content) -> some View {
        if let value = optional {
            modify(self, value)
        } else {
            self
        }
    }
}
