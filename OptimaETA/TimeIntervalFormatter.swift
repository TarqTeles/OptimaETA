//
//  TimeIntervalFormatter.swift
//  OptimaETA
//
//  Created by Tarquinio Teles on 03/09/25.
//

import Foundation

enum TimeIntervalFormatter {
    static func travelTime(for timeInSeconds: TimeInterval, minutesThreshold: TimeInterval = 10.0) -> String {
        let df = DateComponentsFormatter()
        df.unitsStyle = .abbreviated
        df.collapsesLargestUnit = true
        
        if timeInSeconds < 2 * 60.0 {
            df.allowedUnits = [.minute, .second]
        } else {
            df.allowedUnits = [.hour, .minute, .second]
        }
        let excessMinutes = timeInSeconds.truncatingRemainder(dividingBy: 3_600.0) / 60.0
        df.maximumUnitCount = excessMinutes > minutesThreshold ? 2 : 1
        
        return df.string(from: timeInSeconds) ?? "error"

    }
}
