//
//  ConfirmationDialog.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 26/11/2022.
//

import SwiftUI

struct ConfirmationDialog: Identifiable {
    var id = UUID()

    let title: String
    let message: String? = nil
    let primaryButton: String
    let primaryAction: () -> Void

    func actionSheet() -> ActionSheet {
        ActionSheet(
            title: Text(title),
            message: message.map(Text.init),
            buttons: [
                .default(Text(primaryButton), action: primaryAction),
                .cancel()
            ]
        )
    }
}
