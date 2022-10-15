//
//  SwimmerCoachView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 11/10/2022.
//

import SwiftUI

class SwimmerCoachViewModel: ObservableObject {
    @Published var coachs: [Profile] = [
        Profile(userType: .coach, firstName: "Laurent1", lastName: "Dupont", email: "laurent.dupont@ggmail.com"),
        Profile(userType: .coach, firstName: "Laurent2", lastName: "Dupont", email: "laurent.dupont@ggmail.com"),
        Profile(userType: .coach, firstName: "Laurent3", lastName: "Dupont", email: "laurent.dupont@ggmail.com"),
        Profile(userType: .coach, firstName: "Laurent4", lastName: "Dupont", email: "laurent.dupont@ggmail.com"),
        Profile(userType: .coach, firstName: "Laurent5", lastName: "Dupont", email: "laurent.dupont@ggmail.com"),
    ]
    
//    @Published var chosenCoach: Profile?
}

struct SwimmerCoachView: View {
    @StateObject var vm = SwimmerCoachViewModel()
    @State var chosenCoach: Profile?


    var body: some View {
        VStack {
            if let chosenCoach = chosenCoach {
                HStack(alignment: .firstTextBaseline) {
                    Text("You have chosen")
                    Text("\(chosenCoach.fullname)").font(.title3).foregroundColor(Color.mint)
                    Button(action: {self.chosenCoach = nil}) {
                        Image(systemName: "trash").foregroundColor(Color.red)
                    }
                }
            } else {
                Text("Choose a coach in the list")
            }
//            List
            List(vm.coachs, id: \.self, selection: $chosenCoach) { coach in
                HStack(spacing: 20) {
                    Image("ProfilePhoto").resizable().frame(width: 60, height: 60).cornerRadius(8)
                    VStack(alignment: .leading, spacing: 5) {
                        Text("\(coach.fullname)").font(.title2)
                        Text("\(coach.email)").font(.callout)
                    }
                    //                .padding(EdgeInsets(leading:10 ))
                    
                }
                .if(coach == chosenCoach) {
                    $0.listRowBackground(Color.mint.opacity(0.5))
                }
            }
//            .toolbar() {
//                EditButton()
//            }
        }
        .navigationBarTitle("My coach")
    }
}

struct SwimmerCoachView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SwimmerCoachView()
        }
    }
}
