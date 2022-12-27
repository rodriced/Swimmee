//
//  DateExtension.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 27/12/2022.
//

import Foundation

extension Date {
    static var dateNow: Date {
        .now.zeroedTime()
    }

    func zeroedTime() -> Date {
        var dateComponents = Calendar.current.dateComponents(in: TimeZone.current, from: self)
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        dateComponents.nanosecond = 0
        return dateComponents.date!
    }
}
