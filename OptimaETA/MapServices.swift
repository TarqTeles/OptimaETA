//
//  MapServices.swift
//  OptimaETA
//
//  Created by Tarquinio Teles on 04/09/25.
//

import Foundation
import MapKit

class MapServices {
    func searchPlaces(for query: String, in region: MKCoordinateRegion) async -> [MKMapItem] {
        guard query.count > 1 else { return [] }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        
        let search = MKLocalSearch(request: request)
        let response = try? await search.start()
        return response?.mapItems ?? []
    }
    

}
