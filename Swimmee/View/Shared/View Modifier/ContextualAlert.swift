//
//  AlertManager.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 05/11/2022.
//

import SwiftUI

// Helper to make easier alert management

struct ContextualAlertViewModifier<A: View>: ViewModifier {
    @StateObject var context: AlertContext
    var actions: () -> A

    func body(content: Content) -> some View {
        content
            .alert(context.message, isPresented: $context.isPresented, actions: actions)
    }
}

extension View {
    func alert<A: View>(_ context: AlertContext, @ViewBuilder actions: @escaping () -> A) -> some View {
        modifier(ContextualAlertViewModifier<A>(context: context, actions: actions))
    }
}

class AlertContext: ObservableObject {
    @Published var isPresented = false {
        didSet { if !isPresented { message = "" } }
    }

    var message: String = "" {
        didSet {
//            print("AlertContext.message = \(message)")
            if !message.isEmpty { isPresented = true }
        }
    }
}

extension Alert {
    static func retry(title: String, content: String,
                      retryAction: @escaping () -> Void,
                      cancelAction: @escaping () -> Void) -> Alert
    {
        Alert(
            title: Text(title),
            message: Text(content),
            primaryButton: .default(
                Text("Try Again"),
                action: retryAction
            ),
            secondaryButton: .cancel(cancelAction)
        )
    }
}
