//
//  IntegrationTests.swift
//  OptimaETATests
//
//  Created by Tarquinio Teles on 02/09/25.
//

import Testing
import MapKit
import SwiftUI
@testable import OptimaETA

struct IntegrationTests {
    
    @Test func test_MapKit_returnsSearchResults() async throws {
        let sut = MapViewModel(position: .region(ATX.region))
        
        let saltLicksAroundAustin = 2
        let searchString = "salt lick"
        
        await sut.search(for: searchString)
        
        #expect(sut.searchResults.count == saltLicksAroundAustin)
    }
    
    @Test func test_MapKit_doesNotReturnResultsOnShortSearchString() async throws {
        let sut = MapViewModel(position: .region(ATX.region))
        let emptySearchString = ""
        let singleCharacterSearchString = "1"
        
        await sut.search(for: singleCharacterSearchString)
        
        #expect(sut.searchResults.count == 0)
        
        sut.syncSearch(for: emptySearchString)
        
        #expect(sut.searchResults.count == 0)
    }
    
    @Test func test_MapViewModel_allowsMapItemSelection() async throws {
        let sut = MapViewModel(position: .region(ATX.region))
        
        let searchString = "salt lick"
        
        _ = await sut.search(for: searchString)
        
        sut.selection = MapSelection(0)
        
        #expect(sut.selectedMapItem != nil)
        
        let itemName = sut.selectedMapItem!.name!.lowercased()
        #expect(itemName.contains(searchString))
    }
    
    @Test func test_MapViewModel_returnsDestionationItem() async throws {
        let sut = MapViewModel(position: .region(ATX.region))
        
        let searchString = "salt lick"
        
        _ = await sut.search(for: searchString)
        
        var destination = sut.getDestination()
        #expect(destination == nil)
        
        sut.selection = MapSelection(0)
        
        destination = sut.getDestination()
        
        #expect(destination != nil)
        #expect(destination == sut.selectedMapItem)
    }
    
    @Test func test_MapKit_calculatesRoutesToDestionation() async throws {
        let sut = MapViewModel(position: .region(ATX.region))
        
        let searchString = "salt lick"
        
        _ = await sut.search(for: searchString)
        
        sut.selection = MapSelection(1)
        
        let destination = sut.getDestination()
        
        #expect(destination != nil)
        #expect(destination == sut.selectedMapItem)
        
        let routes = await sut.getRoutes()
        
        #expect(routes.count > 0)        
    }
}
