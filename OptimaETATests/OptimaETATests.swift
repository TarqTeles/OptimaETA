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
        let sut = MapViewModel(position: .region(ATX.region), onSearch: spy.onSeachTextChanged)
        
        #expect(spy.searchText == "")

        sut.searchString = "ATX"
        try await Task.sleep(for: .seconds(1))
        
        #expect(spy.searchText == "ATX")
    }

    
    // MARK: - Test Helpers
    
    private class SearchSpy {
        var searchText: String = ""
        
        func onSeachTextChanged(_ text: String) -> Void {
            searchText = text
        }
    }
}
