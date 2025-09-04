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
    private typealias sut = MapServices
    
    @Test func test_MapKit_returnsSearchResults() async throws {
        let (region, _) = makeSUT()

        let saltLicksAroundAustin = 2
        let searchString = "salt lick"
        
        let results = await sut.searchPlaces(for: searchString, in: region)
        
        #expect(results.count == saltLicksAroundAustin)
    }
    
    @Test func test_MapViewModel_allowsMapItemSelection() async throws {
        let (region, vm) = makeSUT()

        let searchString = "salt lick"
        
        vm.searchResults = await sut.searchPlaces(for: searchString, in: region)
        
        vm.selection = MapSelection(0)
        
        #expect(vm.selectedMapItem != nil)
        
        let itemName = vm.selectedMapItem!.name!.lowercased()
        #expect(itemName.contains(searchString))
    }
    
    @Test func test_MapViewModel_returnsDestionationItem() async throws {
        let (region, vm) = makeSUT()
        
        let searchString = "salt lick"
        
        vm.searchResults = await sut.searchPlaces(for: searchString, in: region)

        var destination = vm.destination
        #expect(destination == nil)
        
        vm.selection = MapSelection(0)
        
        destination = vm.destination
        
        #expect(destination != nil)
        #expect(destination == vm.selectedMapItem)
    }
    
    @Test func test_MapKit_calculatesRoutesToDestionation() async throws {
        let (region, vm) = makeSUT()
        
        let searchString = "salt lick"
        
        vm.searchResults = await sut.searchPlaces(for: searchString, in: region)

        vm.selection = MapSelection(1)

        try await Task.sleep(for: .milliseconds(200))

        let destination = vm.destination
        #expect(destination != nil)
        #expect(destination == vm.selectedMapItem)

        while vm.routes.isEmpty {
            try await Task.sleep(for: .seconds(1))
        }

        #expect(vm.routes.count > 0)
    }
    
    // MARK: - Test Helpers
    
    private func makeSUT() -> (region: MKCoordinateRegion, vm: MapViewModel) {
        let atx = ATX.region
        let vm = MapViewModel(position: .region(atx))

        return (atx, vm)
    }
}
