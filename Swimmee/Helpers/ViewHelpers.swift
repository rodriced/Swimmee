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
}
