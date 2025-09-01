//
//  ContentView.swift
//  OptimaETA
//
//  Created by Tarquinio Teles on 29/08/25.
//

import SwiftUI
import MapKit

struct ContentView: View {
    let vm: MapViewModel
    
    var body: some View {
        Map(initialPosition: vm.position) {
            ForEach(vm.searchResults, id: \.self) { result in
                Marker(item: result)
            }
        }
        .mapStyle(.standard(elevation: .realistic, showsTraffic: true))
        .safeAreaInset(edge: .bottom, content: { SearchView(vm: vm).padding(.horizontal) })
    }
}

#Preview {
    ContentView(vm: MapViewModel())
}
