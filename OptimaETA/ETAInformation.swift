//
//  ETAInformation.swift
//  OptimaETA
//
//  Created by Tarquinio Teles on 08/09/25.
//

import Foundation
import MapKit

struct ETAInformation {
    let destinationName: String
    let expectedTravelTime: TimeInterval
    let distance: Measurement<UnitLength>
    let expectedDepartureTime: Date
    let expectedArrivalTime: Date
    
    init(_ response: MKDirections.ETAResponse, locale: Locale = .current) {
        self.destinationName = response.destination.name ?? response.destination.description
        self.expectedTravelTime = response.expectedTravelTime
        self.distance = Measurement(value: response.distance, unit: .init(forLocale: locale))
        self.expectedDepartureTime = response.expectedDepartureDate
        self.expectedArrivalTime = response.expectedArrivalDate
    }
    
    func arrivesBeforeOrAt(_ date: Date) -> Bool {
        return expectedArrivalTime <= date
    }
}
