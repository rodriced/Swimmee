//
//  SwimmerCoachView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 11/10/2022.
//

import SwiftUI

class SwimmerCoachViewModel2: ObservableObject {
//    @Published var coachs: [Profile] = Profile.coachSample.toSamples(with: 4)
    @Published var coachs: [Profile] = []
    @Published var chosenCoachId: String?

    @Published var errorAlertDisplayed = false {
        didSet { if !errorAlertDisplayed { errorAlertMessage = "" } }
    }

    @Published var errorAlertMessage: String = "" {
        didSet { if !errorAlertMessage.isEmpty { errorAlertDisplayed = true } }
    }
    
    
    var chosenCoach: Profile? {
        print("find coach")
        guard let userId = chosenCoachId else { return nil }
        return coachs.first {$0.userId == userId}
    }

    func saveCoach(for userId: String) {
        Task {
            do {
                try await API.shared.profile.updateCoach(for: userId, with: chosenCoachId)
            } catch {
                errorAlertMessage = error.localizedDescription
            }
        }
    }

//    @Published var chosenCoach: Profile?
}

struct SwimmerCoachView2: View {
//    @Environment(\.editMode) var editMode
    @StateObject var vm = SwimmerCoachViewModel2()

    var body: some View {
        VStack {
            if let chosenCoach = vm.chosenCoach {
                HStack(alignment: .firstTextBaseline) {
                    Text("You have chosen")
                    Text("\(chosenCoach.fullname)").font(.title3).foregroundColor(Color.mint)
                    Button(action: { vm.chosenCoachId = nil }) {
                        Image(systemName: "trash").foregroundColor(Color.red)
                    }
                }
            } else {
                Text("Choose a coach in the list")
            }

            List(vm.coachs, id: \.userId, selection: $vm.chosenCoachId) { coach in
                HStack(spacing: 20) {
                    Image("ProfilePhoto").resizable().frame(width: 60, height: 60).cornerRadius(8)
                    VStack(alignment: .leading, spacing: 5) {
                        Text("\(coach.fullname)").font(.title2)
                        Text("\(coach.email)").font(.callout)
                    }
                    //                .padding(EdgeInsets(leading:10 ))
                }
                .if(coach.userId == vm.chosenCoachId) {
                    $0.listRowBackground(Color.mint.opacity(0.5))
                }
            }
//            .onChange(of: vm.chosenCoach) {coach in
//
//            }
            .task {
                do {
                    print("load coachs")
                    vm.coachs = try await API.shared.profile.loadCoachs()
//                    editMode?.wrappedValue.isEditing = true
                } catch {
                    vm.errorAlertMessage = error.localizedDescription
                }
            }
//            .toolbar() {
//                EditButton()
//            }
        }
        .navigationBarTitle("My coach")
        .alert(vm.errorAlertMessage, isPresented: $vm.errorAlertDisplayed) {}
    }
}

struct SwimmerCoachView2_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SwimmerCoachView2()
        }
    }
}
