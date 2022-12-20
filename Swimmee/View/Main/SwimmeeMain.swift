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
        guard NSClassFromString("XCTest") == nil else {
            SwimmeeAppForTesting.main()
            return
        }

        SwimmeeApp.main()
    }
}
