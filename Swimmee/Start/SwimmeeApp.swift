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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
//    init() {
//        #if swift(>=5.7)
//        print("Swift version >= 5.7")
//
//        #elseif swift(>=5.6)
//        print("Swift 5.6")
//
//        #endif
//    }

    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

extension SwimmeeApp {
    static func isUnitTesting() -> Bool {
        return NSClassFromString("SwimmeeUnitTest") != nil
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        //
        guard !SwimmeeApp.isUnitTesting() else { return true }

        FirebaseApp.configure()

        return true
    }
}
