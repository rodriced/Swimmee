//
//  RoutedView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 06/10/2022.
//

import SwiftUI

struct RoutedView: View {
    enum Route { case signup, signin, logged }

    @State var currentRoute = Route.signin

    var body: some View {
        VStack {
            switch currentRoute {
            case .signup:
                SignUpView()
            case .signin:
                SignInView()
            case .logged:
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            }
        }
    }
}

struct RoutedView_Previews: PreviewProvider {
    static var previews: some View {
        RoutedView()
    }
}
