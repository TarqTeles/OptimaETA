//
//  TimeIntervalFormatter.swift
//  OptimaETA
//
//  Created by Tarquinio Teles on 03/09/25.
//

import Foundation

enum TimeIntervalFormatter {
    static func travelTime(for timeInSeconds: TimeInterval) -> String {
        let df = DateComponentsFormatter()
        df.unitsStyle = .abbreviated
        df.allowedUnits = [.hour, .minute, .second]
        df.maximumUnitCount = 1
        df.collapsesLargestUnit = true
                
        return df.string(from: timeInSeconds) ?? "error"

    }
}
