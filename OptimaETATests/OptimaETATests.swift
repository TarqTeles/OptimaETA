//
//  OptimaETATests.swift
//  OptimaETATests
//
//  Created by Tarquinio Teles on 29/08/25.
//

import Testing
@testable import OptimaETA

struct OptimaETATests {

    @Test func test_automaticSearchOnStringChangeAfterDebounce() async throws {
        let spy = SearchSpy()
        let sut = MapViewModel(position: .region(ATX.region), onSearch: spy.updateText)
        
        #expect(spy.searchText == "")
        try await Task.sleep(for: .milliseconds(200))

        sut.searchString = "ATX"
        try await Task.sleep(for: .milliseconds(600))

        #expect(spy.searchText == sut.searchString)
    }

    
    // MARK: - Test Helpers
    
    private class SearchSpy {
        var searchText: String = ""
        
        func updateText(to text: String) -> Void {
            searchText = text
        }
    }
}
