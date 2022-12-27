//
//  TimeHelper.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 27/12/2022.
//

import Foundation

class TimeHelper {
    static func formatToClockTime(timeInMinutes: Int) -> String {
        let hours = timeInMinutes / 60
        let minutes = timeInMinutes % 60
        let formatedMinutes = minutes < 10 ? "0\(minutes)" : "\(minutes)"

        return "\(hours)h\(formatedMinutes)"
    }
}
