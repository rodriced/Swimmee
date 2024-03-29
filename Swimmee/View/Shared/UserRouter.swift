//
//  UserRouter.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 19/12/2022.
//

import Combine

// UserRouter is a the main router to manage direct access to the pages of the application authenticated parts

class UserRouter: ObservableObject {
    enum TabTarget: Hashable { case workouts, messages, settings }
    enum SettingTarget: Hashable { case profile, coachSelection, team }
    
    @Published var tabsTarget = TabTarget.workouts
    @Published var settingsTarget: SettingTarget?
    
    func routeTo(tab target: TabTarget) {
        tabsTarget = target
    }

    func routeTo(setting target: SettingTarget) {
        tabsTarget = .settings
        settingsTarget = target
    }
}
