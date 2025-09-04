//
//  SelectedDestinationViewModel.swift
//  OptimaETA
//
//  Created by Tarquinio Teles on 04/09/25.
//

import Foundation
import SwiftUI
import MapKit

class SelectedDestinationViewModel {
    var selection: MapSelection<Int>?
    var selectedMapFeature: MapFeature?
    var selectedMapItem: MKMapItem?
    var destination: MKMapItem? { getDestination() }
    
    
    func onSelection(using searchResults: [MKMapItem]) -> MKMapItem? {
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
        return getDestination()
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
