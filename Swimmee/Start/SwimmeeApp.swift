//
//  SwimmeeApp.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 27/09/2022.
//

import FirebaseCore
import SwiftUI

@main
struct SwimmeeApp: App {
//    @StateObject var session = Session()

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

//    init() {
//        FirebaseApp.configure()
//    }

    var body: some Scene {
        WindowGroup {
//            ContentView()
            MainView()
//                .environmentObject(session)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()

        return true
    }
}
