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
        
        if timeInSeconds < 10 * 60.0 - 1.0 {
            df.allowedUnits = [.minute, .second]
        } else {
            df.allowedUnits = [.hour, .minute]
        }
        
        let significant = timeInSeconds > 3_600.0 || timeInSeconds < 240.0
        df.maximumUnitCount = significant ? 2 : 1
        
        return df.string(from: timeInSeconds) ?? "error"
    }
}
