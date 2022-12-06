//
//  AlertManager.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 05/11/2022.
//

import SwiftUI

struct ContextualAlertViewModifier: ViewModifier {
    @StateObject var context: AlertContext

    func body(content: Content) -> some View {
        let alertContent = context.content ?? .message("")
        
        switch alertContent {
        case let .message(message):
            content
                .alert(message, isPresented: $context.isPresented) {}
        case let .alert(alert):
            content
                .alert(isPresented: $context.isPresented, content: alert)
        }
    }
}

extension View {
    func alert(_ context: AlertContext) -> some View {
        modifier(ContextualAlertViewModifier(context: context))
    }
}

class AlertContext: ObservableObject {
    enum AlertContent {
        case message(String)
        case alert(() -> Alert)
    }

    @Published var isPresented = false {
        didSet { if !isPresented { content = nil } }
    }

    var content: AlertContent? {
        didSet {
            if content != nil { isPresented = true }
        }
    }
}

extension Alert {
    static func tryAgain(title: String, message: String,
                      retryAction: @escaping () -> Void,
                      cancelAction: @escaping () -> Void) -> Alert
    {
        Alert(
            title: Text(title),
            message: Text(message),
            primaryButton: .default(
                Text("Try Again"),
                action: retryAction
            ),
            secondaryButton: .cancel(cancelAction)
        )
    }
}
