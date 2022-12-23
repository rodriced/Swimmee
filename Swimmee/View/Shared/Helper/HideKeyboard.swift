//
//  HideKeyboard.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 23/12/2022.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}
