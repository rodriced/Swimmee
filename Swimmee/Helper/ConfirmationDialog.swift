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
    let message: String?
    let primaryButton: String
    let primaryAction: () -> Void
    let isDestructive: Bool

    init(title: String,
         message: String? = nil,
         primaryButton: String,
         primaryAction: @escaping () -> Void,
         isDestructive: Bool = false)
    {
        self.title = title
        self.message = message
        self.primaryButton = primaryButton
        self.primaryAction = primaryAction
        self.isDestructive = isDestructive
    }

    func actionSheet() -> ActionSheet {
        ActionSheet(
            title: Text(title),
            message: message.map(Text.init),
            buttons: [
                isDestructive ?
                    .destructive(Text(primaryButton), action: primaryAction)
                    :
                    .default(Text(primaryButton), action: primaryAction),
                .cancel()
            ]
        )
    }
}
