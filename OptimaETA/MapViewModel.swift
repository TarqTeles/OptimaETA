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
    let maps = MapServices()
    var searchString: String {
        didSet {
            if oldValue.trimmed != searchString.trimmed {
                searchPublisher.send(searchString.trimmed)
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
    var routes: [MKRoute] = []
    
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
        routes = []
    }
    
    func syncSearch(for query: String) {
        Task(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            
            if let region = self.visibleRegion {
                searchResults = await self.maps.searchPlaces(for: query, in: region)
            } else if let region = self.position.region {
                searchResults = await self.maps.searchPlaces(for: query, in: region)
            }
        }
    }
    
    private func onSelection() {
        routes = []
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
        if let dest = getDestination() {
            Task {
                try? await Task.sleep(for: .milliseconds(100))
                routes = await maps.getRoutes(to: dest)
            }
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
}

extension String {
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
