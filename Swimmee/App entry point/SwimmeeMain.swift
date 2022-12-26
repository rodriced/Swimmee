//
//  SwimmeeMain.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 08/12/2022.
//

import Foundation

@main
enum SwimmeeMain {
    static func main() {
        //
        // When unit testing is detected, a minimal user interface is used
        //
        guard NSClassFromString("XCTest") == nil else {
            SwimmeeAppForTesting.main()
            return
        }

        SwimmeeApp.main()
    }
}
