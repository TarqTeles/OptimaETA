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
    private typealias maps = MapServices
    private let selectVM = SelectedDestinationViewModel()
    private let routesVM = RoutesETAViewModel()

    private let searchPublisher = PassthroughSubject<String, Never>()
    private let searchOnMainQueue = DispatchQueue.main
    private var searchCancellable: AnyCancellable?

    var position: MapCameraPosition
    var visibleRegion: MKCoordinateRegion?

    var searchString: String {
        didSet {
            if oldValue.trimmed != searchString.trimmed {
                searchPublisher.send(searchString.trimmed)
            }
        }
    }
    var searchResults: [MKMapItem]
    var isSearching: Bool { !searchString.isEmpty }
    
    var selection: MapSelection<Int>? {
        get {
            selectVM.selection
        }
        set {
            if let dest = selectVM.setSelection(newValue, using: searchResults) {
                routesVM.updateRoutes(to: dest)
            }
        }
    }
    var selectedMapFeature: MapFeature? { selectVM.selectedMapFeature }
    var selectedMapItem: MKMapItem? { selectVM.selectedMapItem }
    var destination: MKMapItem? { selectVM.destination }

    var routes: [MKRoute] { routesVM.currentRoutes }
    var etaSeries: [ETAInformation] { routesVM.etaSeries }
    var fastestTravelTime: TimeInterval { routesVM.fastestTravelTime }
    var earliestETA: Date { routesVM.earliestETA }
    
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
            .removeDuplicates()
            .subscribe(on: searchOnMainQueue)
            .sink(receiveValue: onSearch ?? self.syncSearch)
    }
    
    func clearSearchString() {
        searchString = ""
        selection = nil
        routesVM.clearAll()
    }
    
    func syncSearch(for query: String) {
        Task(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            
            if let region = self.visibleRegion {
                searchResults = await maps.searchPlaces(for: query, in: region)
            } else if let region = self.position.region {
                searchResults = await maps.searchPlaces(for: query, in: region)
            }
        }
    }
    
    func getETAs() async {
        if let dest = destination {
            try? await routesVM.updateETASeries(to: dest)
        }
    }
}

extension String {
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
