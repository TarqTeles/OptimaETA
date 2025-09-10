//
//  RoutesETAViewModel.swift
//  OptimaETA
//
//  Created by Tarquinio Teles on 08/09/25.
//

import Foundation
import MapKit

@Observable class RoutesETAViewModel {
    private typealias maps = MapServices
    var currentRoutes: [MKRoute] = []
    var routesQueryTask: Task<Void, Error>?
    var etaSeries: [ETAInformation] = []
    var fastestTravelTime: TimeInterval = .infinity
    var earliestETA: Date = .distantFuture

    func updateRoutes(to destination: MKMapItem) {
        clearAll()
        routesQueryTask = Task {
            self.currentRoutes = await maps.getRoutes(to: destination)
        }
    }
    
    func updateETASeries(to destination: MKMapItem,
                         intervals: Int = 12,
                         lasting: TimeInterval = 5 * 60.0,
                         starting: Date = .now
    ) async throws {
        var series: [ETAInformation?] = .init(repeating: nil, count: intervals)
        var responses: Int = 0
        try await withThrowingTaskGroup { group in
            for i in 0..<intervals {
                group.addTask {
                    let delay = TimeInterval(i) * lasting
                    let dep = starting.addingTimeInterval(delay)
                    let response = try await MapServices.getETA(at: destination, departure: dep)
                    return (i, response)
                    
                }
            }
            for try await result in group {
                responses += 1
                let myLabel = result.0 == 0 ? "Now" : TimeIntervalFormatter.travelTime(for: Double(result.0) * lasting)
                let info = ETAInformation(result.1, label: myLabel)
                series[result.0] = info
                if info.expectedTravelTime < fastestTravelTime {
                    fastestTravelTime = info.expectedTravelTime
                }
                if info.expectedArrivalTime < earliestETA {
                    earliestETA = info.expectedArrivalTime
                }
            }
        }
        etaSeries = series.compactMap(\.self)
    }
    
    func clearAll() {
        routesQueryTask?.cancel()
        currentRoutes = []
        etaSeries.removeAll(keepingCapacity: true)
        earliestETA = .distantFuture
        fastestTravelTime = .infinity
    }
}
