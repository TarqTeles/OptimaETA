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
            if oldValue != searchString {
                searchPublisher.send(searchString)
            }
        }
    }
    var searchResults: [MKMapItem]
    var selection: MapSelection<Int>? {
        didSet {
            onSelection()
        }
    }
    var selectedMapFeature: MapFeature?
    var selectedMapItem: MKMapItem?
    var position: MapCameraPosition
    var visibleRegion: MKCoordinateRegion?
    
    private let searchPublisher = PassthroughSubject<String, Never>()
    private let searchOnMainQueue = DispatchQueue.main
    private var searchCancellable: AnyCancellable?
    
    var isSearching: Bool { !searchString.isEmpty }
    
    init(searchString: String = "",
         searchResults: [MKMapItem] = [],
         position: MapCameraPosition = .userLocation(fallback: .region(ATX.region)),
         onSearch: ((String) -> Void)? = nil
    ) {
        self.searchString = searchString
        self.searchResults = searchResults
        self.position = position
                
        searchCancellable = searchPublisher
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .subscribe(on: searchOnMainQueue)
            .sink(receiveValue: onSearch ?? self.syncSearch)
    }
    
    func clearSearchString() {
        searchString = ""
        selection = nil
    }
    
    func syncSearch(for query: String) {
        Task(priority: .userInitiated) {
            await self.search(for: query)
        }
    }
    
    func search(for query: String) async {
        guard query.count > 1 else { return }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        if let region = visibleRegion {
            request.region = region
        } else if let region = position.region {
            request.region = region
        }
        
        let search = MKLocalSearch(request: request)
        let response = try? await search.start()
        searchResults = response?.mapItems ?? []
    }
    
    private func onSelection() {
        if let feature = selection?.feature {
            self.selectedMapFeature = feature
            self.selectedMapItem = nil
        } else if let id = selection?.value {
            let choices = searchResults.enumerated()
            if let pair = (choices.first(where: { $0.offset == id })) {
                self.selectedMapItem = pair.element
                self.selectedMapFeature = nil
            }
        } else if selection == nil {
            self.selectedMapFeature = nil
            self.selectedMapItem = nil
        }
    }
    
    func getDestination() -> MKMapItem? {
        if let item = selectedMapItem {
            return item
        } else if let feature = selectedMapFeature {
            return MKMapItem(placemark: .init(coordinate: feature.coordinate))
        } else {
            return nil
        }
    }
    
    func getRoutes() async -> [MKRoute] {
        guard let item = getDestination() else { return [] }
        
        let request = MKDirections.Request()
        request.source = .forCurrentLocation()
        request.destination = item
        request.requestsAlternateRoutes = true
        request.transportType = .any
        
        let response = try? await MKDirections(request: request).calculate()
        
        return response?.routes ?? []
    }
}
