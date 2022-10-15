//
//  MenuLabel.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 10/10/2022.
//

import SwiftUI

struct MenuLabel: View {
    let title: String
    let systemImage: String
    let color: Color

    var body: some View {
        Label { Text(title) } icon: {
            Image(systemName: systemImage)
//                .padding(10)
                .frame(width: 35, height: 35)
                .background(color)
                .foregroundColor(Color.white)
                .cornerRadius(8)
        }.padding(1)
    }
}

struct MenuLabel_Previews: PreviewProvider {
    static var previews: some View {
        MenuLabel(title: "My profile", systemImage: "person", color: Color.mint)    }
}
