//
//  MapViewModel.swift
//  OptimaETA
//
//  Created by Tarquinio Teles on 29/08/25.
//

import SwiftUI
import MapKit

@Observable class MapViewModel {
    var searchString: String = ""
    var searchResults: [MKMapItem] = []
    var position: MapCameraPosition = .userLocation(fallback: .region(ATX.region))
 
    
    func search(for query: String) async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        if let region = position.region {
            request.region = region
        }
        
        let search = MKLocalSearch(request: request)
        let response = try? await search.start()
        searchResults = response?.mapItems ?? []
    }
}

private struct ATX {
    static let coordinate: CLLocationCoordinate2D = .init(latitude: +30.20219090, longitude: -97.66659810)
    static let marker = MKMapItem(placemark: .init(coordinate: coordinate))
    static let region = MKCoordinateRegion(center: coordinate,
                                           span: .init(
                                            latitudeDelta: 0.5,
                                            longitudeDelta: 0.5))
}
