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
    
    @Test func test_TimeIntervalFormatter_properlyFormatsTravelTime() {
        let justFiveSeconds: TimeInterval = 5.0
        let almostAMinute: TimeInterval = 59.6
        let fiveMinutesFiftyFiveSeconds: TimeInterval = 5 * 60.0 + 55.0
        let twoHoursFiveMinutesFiftyFiveSeconds: TimeInterval = 2 * 60.0 * 60.0 + 5 * 60.0 + 55.0
        let OneDayAndOneMinute: TimeInterval = 24 * 60.0 * 60.0 + 60.0

        typealias SUT = TimeIntervalFormatter
        
        #expect(SUT.travelTime(for: justFiveSeconds) == "5s")
        #expect(SUT.travelTime(for: almostAMinute) == "59s")
        #expect(SUT.travelTime(for: fiveMinutesFiftyFiveSeconds) == "00:05")
        #expect(SUT.travelTime(for: twoHoursFiveMinutesFiftyFiveSeconds) == "02:05")
        #expect(SUT.travelTime(for: OneDayAndOneMinute) == "00:01 + 1d")
    }

    
    // MARK: - Test Helpers
    
    private class SearchSpy {
        var searchText: String = ""
        
        func updateText(to text: String) -> Void {
            searchText = text
        }
    }
}
