//
//  MapServices.swift
//  OptimaETA
//
//  Created by Tarquinio Teles on 04/09/25.
//

import Foundation
import MapKit

enum MapServices {
    static func searchPlaces(for query: String, in region: MKCoordinateRegion) async -> [MKMapItem] {
        guard query.count > 1 else { return [] }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        
        let search = MKLocalSearch(request: request)
        let response = try? await search.start()
        return response?.mapItems ?? []
    }
    
    static func getRoutes(to item: MKMapItem) async -> [MKRoute] {
        let request = MKDirections.Request()
        request.source = .forCurrentLocation()
        request.destination = item
        request.requestsAlternateRoutes = true
        request.transportType = .any
        
        let response = try? await MKDirections(request: request).calculate()
        
        return response?.routes ?? []
    }
    
    static func getETA(at item: MKMapItem, departure: Date = .now) async throws -> MKDirections.ETAResponse {
        let request = MKDirections.Request()
        request.source = .forCurrentLocation()
        request.destination = item
        request.departureDate = departure
        
        let response = try await MKDirections(request: request).calculateETA()

        return response
    }
}
