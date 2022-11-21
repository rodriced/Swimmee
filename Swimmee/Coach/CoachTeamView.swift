//
//  CoachTeamView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 11/10/2022.
//

import SwiftUI

class CoachTeamViewModel: ObservableObject {
    @Published var swimmers: [Profile] = Profile.swimmerSample.toSamples(with: 5)
    var images: [String: UIImage] = [:]

    @Published var errorAlertDisplayed = false {
        didSet { if !errorAlertDisplayed { errorAlertMessage = "" } }
    }

    @Published var errorAlertMessage: String = "" {
        didSet { errorAlertDisplayed = !errorAlertMessage.isEmpty }
    }

    @MainActor
    func loadTeam() async {
        print("load team")

        do {
            swimmers = try await API.shared.profile.loadTeam()
            for swimmer in swimmers {
                let imageData = try? await API.shared.imageStorage.downloadd(uid: swimmer.userId)
                guard let imageData = imageData else {
                    continue
                }
                images[swimmer.userId] = UIImage(data: imageData)
            }
        } catch {
            swimmers = []
            images = [:]
            errorAlertMessage = error.localizedDescription
        }
    }
}

struct CoachTeamView: View {
    @StateObject var vm = CoachTeamViewModel()

    var body: some View {
        List(vm.swimmers) { swimmer in
            HStack(spacing: 20) {
                Group {
                    if let image = vm.images[swimmer.userId] {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Image("ProfilePhoto")
                            .resizable()
                    }
                }
                .frame(width: 60, height: 60).cornerRadius(8)
//                Image("ProfilePhoto").resizable().frame(width: 60, height: 60).cornerRadius(8)
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(swimmer.firstName) \(swimmer.lastName)").font(.title2)
                    Text("\(swimmer.email)").font(.callout)
                }
                //                .padding(EdgeInsets(leading:10 ))
            }
        }
        .task {
            await vm.loadTeam()
        }
        .refreshable {
            await vm.loadTeam()
        }
        .navigationBarTitle("My team")
        .alert(vm.errorAlertMessage, isPresented: $vm.errorAlertDisplayed) {}
    }
}

struct CoachTeamView_Previews: PreviewProvider {
    static var previews: some View {
        CoachTeamView()
    }
}
