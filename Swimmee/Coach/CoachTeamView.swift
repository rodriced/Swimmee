//
//  CoachTeamView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 11/10/2022.
//

import SwiftUI

class CoachTeamViewModel: ObservableObject {
    @Published var swimmers: [Profile] = [
        Profile(userType: .swimmer, firstName: "Laurent", lastName: "Dupont", email: "laurent.dupont@ggmail.com"),
        Profile(userType: .swimmer, firstName: "Laurent", lastName: "Dupont", email: "laurent.dupont@ggmail.com"),
        Profile(userType: .swimmer, firstName: "Laurent", lastName: "Dupont", email: "laurent.dupont@ggmail.com"),
        Profile(userType: .swimmer, firstName: "Laurent", lastName: "Dupont", email: "laurent.dupont@ggmail.com"),
        Profile(userType: .swimmer, firstName: "Laurent", lastName: "Dupont", email: "laurent.dupont@ggmail.com"),
    ]
}

struct CoachTeamView: View {
    @StateObject var vm = CoachTeamViewModel()

    var body: some View {
        List(vm.swimmers) { swimmer in
            HStack(spacing: 20) {
                Image("ProfilePhoto").resizable().frame(width: 60, height: 60).cornerRadius(8)
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(swimmer.firstName) \(swimmer.lastName)").font(.title2)
                    Text("\(swimmer.email)").font(.callout)
                }
                //                .padding(EdgeInsets(leading:10 ))
                
            }
        }
        .navigationBarTitle("My team")
    }
}

struct CoachTeamView_Previews: PreviewProvider {
    static var previews: some View {
        CoachTeamView()
    }
}
