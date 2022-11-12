//
//  DebugHelpers.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 24/10/2022.
//

import Foundation
import SwiftUI

class DebugHelper {
    static func viewBodyPrint(_ message: String = "") -> EmptyView {
        debugPrint(message)
        return EmptyView()
    }
}
