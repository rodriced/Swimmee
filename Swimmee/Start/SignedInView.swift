//
//  SignedInView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 06/10/2022.
//

import SwiftUI

struct SignedInView: View {
   @EnvironmentObject var session: UserSession

    var body: some View {
        Group {
            switch session.userType {
            case .coach:
                CoachMainView()
            case .swimmer:
                SwimmerMainView()
            }
        }
    }
    
}

struct SignedInView_Previews: PreviewProvider {
    static var previews: some View {
        SignedInView()
    }
}
