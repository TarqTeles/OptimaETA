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
    var etaSeries: [ETAInformation] = []
    var routesQueryTask: Task<Void, Error>?

    func updateRoutes(to destination: MKMapItem) {
        clearAll()
        routesQueryTask = Task {
            self.currentRoutes = await maps.getRoutes(to: destination)
        }
    }
    
    func clearAll() {
        routesQueryTask?.cancel()
        currentRoutes = []
        etaSeries.removeAll(keepingCapacity: true)
    }
}
