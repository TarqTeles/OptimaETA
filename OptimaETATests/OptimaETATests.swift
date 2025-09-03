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
        let fiveMinutesFiftySeconds: TimeInterval = 5 * 60.0 + 50.0
        let twoHoursThirtyFiveMinutes: TimeInterval = 2 * 60.0 * 60.0 + 35 * 60.0
        let OneDayAndFiftyMinutes: TimeInterval = 24 * 60.0 * 60.0 + 50 * 60.0

        typealias SUT = TimeIntervalFormatter
        
        #expect(SUT.travelTime(for: justFiveSeconds) == "5s")
        #expect(SUT.travelTime(for: almostAMinute) == "59s")
        #expect(SUT.travelTime(for: fiveMinutesFiftySeconds) == "6m")
        #expect(SUT.travelTime(for: twoHoursThirtyFiveMinutes) == "3h")
        #expect(SUT.travelTime(for: OneDayAndFiftyMinutes) == "25h")
    }

    
    // MARK: - Test Helpers
    
    private class SearchSpy {
        var searchText: String = ""
        
        func updateText(to text: String) -> Void {
            searchText = text
        }
    }
}
