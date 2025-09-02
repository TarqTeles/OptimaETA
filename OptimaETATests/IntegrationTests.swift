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
    
    @Test func test_MapKit_allowsMapItemSelection() async throws {
        let sut = MapViewModel(position: .region(ATX.region))
        
        let searchString = "salt lick"
        
        _ = await sut.search(for: searchString)
        
        sut.selection = MapSelection(0)
        
        #expect(sut.selectedMapItem != nil)
        
        let itemName = sut.selectedMapItem!.name!.lowercased()
        #expect(itemName.contains(searchString))
    }

}
