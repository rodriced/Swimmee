//
//  AppTitleView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 07/10/2022.
//

import SwiftUI

// Main application title with image

struct AppTitleView: View {
    var body: some View {
        ZStack {
            Image("SwimmeeLogo")
//                .resizable(capInsets: EdgeInsets(), resizingMode: .stretch)
                .resizable(resizingMode: .stretch)
                .frame(width: 200, height: 150)
            Text("swimmee")
                .font(.system(size: 34, weight: .regular))
                .foregroundColor(.mint)
                .offset(y: 80)
        }.padding()
    }
}

struct AppTitleView_Previews: PreviewProvider {
    static var previews: some View {
        AppTitleView()
    }
}
