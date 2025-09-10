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
    
    @Test func test_MapViewModel_returnsDestinationItem() async throws {
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
    
    @Test func test_MapKit_calculatesRoutesToDestination() async throws {
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
    
    @Test func test_MapKit_calculatesETAToDestination() async throws {
        let (region, vm) = makeSUT()
        
        let searchString = "salt lick"
        
        vm.searchResults = await sut.searchPlaces(for: searchString, in: region)
        
        let destination = vm.searchResults[1]
        
        let response = try await MapServices.getETA(at: destination)
        
        #expect(response.destination == destination)
        #expect(response.expectedDepartureDate < response.expectedArrivalDate)
    }
    
    @Test func test_MapKit_calculatesETAToDestinationOnLaterDeparture() async throws {
        let (region, vm) = makeSUT()
        let inFiveMinutes = Date(timeIntervalSinceNow: 5 * 60.0)
        
        let searchString = "salt lick"
        
        vm.searchResults = await sut.searchPlaces(for: searchString, in: region)
        
        let destination = vm.searchResults[1]
        
        let response = try await MapServices.getETA(at: destination, departure: inFiveMinutes)
        
        #expect(response.destination == destination)
        #expect(response.expectedDepartureDate == inFiveMinutes)
        
        let info = ETAInformation(response)
        
        #expect(info.destinationName == response.destination.name!)
        #expect(info.expectedTravelTime == response.expectedTravelTime)
        #expect(info.expectedDepartureTime == inFiveMinutes)
        #expect(info.arrivesBeforeOrAt(inFiveMinutes) == false)
    }

    @Test func test_RoutesETAVM_populatesETAToUseInChart() async throws {
        let (region, vm) = makeSUT()
        let etaVM = RoutesETAViewModel()
        let eightIntervals = 8
        let fiveMinutes = 5 * 60.0
        let start = Date()
        
        let searchString = "salt lick"
        
        vm.searchResults = await sut.searchPlaces(for: searchString, in: region)
        
        let destination = vm.searchResults[1]
        
        try await etaVM.updateETASeries(to: destination, intervals: eightIntervals, lasting: fiveMinutes, starting: start)
        
        let series = etaVM.etaSeries
        let last = eightIntervals - 1
        #expect(series.count == eightIntervals)
        #expect(series[0].expectedDepartureTime == start)
        #expect(series[last].expectedDepartureTime == start.addingTimeInterval(Double(last) * fiveMinutes))

        let earliestETA = series.map({ $0.expectedArrivalTime }).sorted().first!
        let fastestTravelTime = series.map({ $0.expectedTravelTime }).sorted().first!
        
        #expect(etaVM.earliestETA == earliestETA)
        #expect(etaVM.fastestTravelTime == fastestTravelTime)
    }
    

    // MARK: - Test Helpers
    
    private func makeSUT() -> (region: MKCoordinateRegion, vm: MapViewModel) {
        let atx = ATX.region
        let vm = MapViewModel(position: .region(atx))

        return (atx, vm)
    }
}
