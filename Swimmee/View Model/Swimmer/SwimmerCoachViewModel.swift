//
//  SwimmerCoachViewModel.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 11/10/2022.
//

import Combine
import SwiftUI

class SwimmerCoachViewModel: ObservableObject {
    let profileAPI: ProfileSwimmerAPI

    init(profileAPI: ProfileSwimmerAPI = API.shared.profile) {
        self.profileAPI = profileAPI
    }


    enum ViewState: Equatable {
        case loading
        case normal
        case info(String)
    }

    @Published var state = ViewState.loading

    @Published var coachs: [Profile] = []
    @Published var currentCoach: Profile?

    @Published var alertContext = AlertContext()

    @Published var confirmationPresented = false {
        didSet {
            if !confirmationPresented { confirmation = Self.emptyConfirmation }
        }
    }

    typealias Confirmation = (title: String, message: String, button: () -> Button<Text>)
    var confirmation: Confirmation = SwimmerCoachViewModel.emptyConfirmation

    static let emptyConfirmation: Confirmation = (title: "", message: "", button: { Button("") {}})

    func presentSubscribeConfirmation(coach: Profile) {
        confirmation = (
            title: "Subscribing to a coach",
            message: "You are going to subcribe to \(coach.fullname).",
            button: {
                Button("Subscribe to \(coach.fullname)") { self.saveSelectedCoach(coach) }
            }
        )
        confirmationPresented = true
    }

    func presentUnsubscribeConfirmation(coach: Profile) {
        confirmation = (
            title: "Unsubscribe from your coach",
            message: "You are going to unsubcribe from \(coach.fullname).",
            button: {
                Button("Unsubscribe") { self.saveSelectedCoach(nil) }
            }
        )
        confirmationPresented = true
    }

    func presentReplaceConfirmation(currentCoach: Profile, newCoach: Profile) {
        confirmation = (
            title: "Replace your current coach",
            message: "You are going to unsubcribe from \(currentCoach.fullname) and subscribe to \(newCoach.fullname).",
            button: {
                Button("Replace with \(newCoach.fullname)") { self.saveSelectedCoach(newCoach) }
            }
        )
        confirmationPresented = true
    }

    @MainActor
    func loadCoachs(withSelected coachId: UserId?) async {
        do {
            state = .loading

            let coachs = try await profileAPI.loadCoachs()

            guard !coachs.isEmpty else {
                state = .info("No coach available for now.\nCome back later.")
                return
            }

            guard let coachId else {
                self.coachs = coachs
                self.currentCoach = nil
                state = .normal
                return
            }

            let currentCoach = coachs.first { profile in
                profile.userId == coachId
            }

            guard currentCoach != nil else {
                state = .info("Can't find your coach in the list of available coachs.\nCome back later or ask administration for help.")
                return
            }

            self.coachs = coachs
            self.currentCoach = currentCoach
            state = .normal

        } catch {
            state = .info(error.localizedDescription)
        }
    }

    func saveSelectedCoach(_ coach: Profile?) {
        Task {
            do {
                try await profileAPI.updateCoach(with: coach?.userId)
                await MainActor.run {
                    currentCoach = coach
                }
            } catch {
                await MainActor.run {
                    alertContext.message = error.localizedDescription
                }
            }
        }
    }
}
