//
//  TimeIntervalFormatter.swift
//  OptimaETA
//
//  Created by Tarquinio Teles on 03/09/25.
//

import Foundation

enum TimeIntervalFormatter {
    static func travelTime(for timeInSeconds: TimeInterval) -> String {
        guard timeInSeconds >= 60.0 else {
            return "\(Int(timeInSeconds))s"
        }
        let date = Date(timeIntervalSinceReferenceDate: timeInSeconds)
        let df = DateFormatter()
        df.locale = Locale(identifier: "pt_BR")
        df.timeZone = .gmt
        df.dateFormat = .none
        df.timeStyle = .short
        
        if timeInSeconds < 24 * 60.0 * 60.0 {
            return df.string(from: date)
        } else {
            let days = Int(timeInSeconds / (24 * 60.0 * 60.0))
            return "\(df.string(from: date)) + \(days)d"
        }
    }
}
