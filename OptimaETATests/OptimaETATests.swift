//
//  OptimaETATests.swift
//  OptimaETATests
//
//  Created by Tarquinio Teles on 29/08/25.
//

import Testing
@testable import OptimaETA
import Foundation

struct OptimaETATests {

    @Test func test_automaticSearchOnStringChangeAfterDebounce() async throws {
        let spy = SearchSpy()
        let sut = MapViewModel(position: .region(ATX.region), onSearch: spy.updateText)
        
        #expect(spy.searchText == "")
        try await Task.sleep(for: .milliseconds(200))

        sut.searchString = "Salt lick"
        try await Task.sleep(for: .milliseconds(600))

        #expect(spy.searchText == sut.searchString)

        sut.clearSearchString()
        try await Task.sleep(for: .milliseconds(600))
        
        #expect(spy.searchText == "")
        #expect(sut.searchResults.isEmpty)
    }
    
    @Test func test_MapKit_doesNotReturnResultsOnShortSearchString() async throws {
        let spy = SearchSpy()
        let sut = MapViewModel(position: .region(ATX.region), onSearch: spy.updateText)
        
        let emptySearchString = ""
        let singleCharacterSearchString = "1"
        
        #expect(spy.searchText == "")
        try await Task.sleep(for: .milliseconds(200))

        sut.searchString = singleCharacterSearchString
        try await Task.sleep(for: .milliseconds(200))

        #expect(spy.searchText == "")
        
        sut.searchString = emptySearchString
        try await Task.sleep(for: .milliseconds(200))
        
        #expect(spy.searchText == "")
    }
    
    @Test func test_TimeIntervalFormatter_properlyFormatsTravelTime() {
        let justFiveSeconds: TimeInterval = 5.0
        let almostAMinute: TimeInterval = 59.6
        let almostTwoMinutes: TimeInterval = 1 * 60.0 + 39.6
        let fiveMinutesFiftySeconds: TimeInterval = 5 * 60.0 + 50.0
        let fiftyMinutesTenSeconds: TimeInterval = 50 * 60.0 + 10.0
        let twoHoursThirtyFiveMinutes: TimeInterval = 2 * 60.0 * 60.0 + 35 * 60.0
        let OneDayAndFifteenMinutes: TimeInterval = 24 * 60.0 * 60.0 + 15 * 60.0

        typealias SUT = TimeIntervalFormatter
        
        #expect(SUT.travelTime(for: justFiveSeconds) == "5s")
        #expect(SUT.travelTime(for: almostAMinute) == "59s")
        #expect(SUT.travelTime(for: almostTwoMinutes) == "1m 39s")
        #expect(SUT.travelTime(for: fiveMinutesFiftySeconds) == "6m")
        #expect(SUT.travelTime(for: fiftyMinutesTenSeconds) == "50m")
        #expect(SUT.travelTime(for: twoHoursThirtyFiveMinutes) == "2h 35m")
        #expect(SUT.travelTime(for: OneDayAndFifteenMinutes) == "24h 15m")
    }

    
    // MARK: - Test Helpers
    
    private class SearchSpy {
        var searchText: String = ""
        
        func updateText(to text: String) -> Void {
            searchText = text
        }
    }
}
