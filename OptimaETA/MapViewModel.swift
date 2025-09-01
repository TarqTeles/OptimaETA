//
//  MapViewModel.swift
//  OptimaETA
//
//  Created by Tarquinio Teles on 29/08/25.
//

import SwiftUI
import Combine
import MapKit

@Observable class MapViewModel {
    var searchString: String {
        didSet {
            if !oldValue.isEmpty && oldValue != searchString {
                searchPublisher.send(searchString)
            }
        }
    }
    var searchResults: [MKMapItem]
    var selection: MKMapItem?
    var position: MapCameraPosition
    
    private let searchPublisher = PassthroughSubject<String, Never>()
    private let searchOnMainQueue = DispatchQueue.main
    private var searchCancellable: AnyCancellable?
    
    var isSearching: Bool { !searchString.isEmpty }
    
    init(searchString: String = "",
         searchResults: [MKMapItem] = [],
         position: MapCameraPosition = .userLocation(fallback: .region(ATX.region))
    ) {
        self.searchString = searchString
        self.searchResults = searchResults
        self.position = position
        
        searchCancellable = searchPublisher
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .subscribe(on: searchOnMainQueue)
            .sink(receiveValue: self.syncSearch)
    }
    
    func syncSearch(for query: String) {
        Task(priority: .userInitiated) {
            await self.search(for: query)
        }
    }
    
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
    
    func clearSearchString() {
        searchString = ""
        selection = nil
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
