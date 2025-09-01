//
//  ContentView.swift
//  OptimaETA
//
//  Created by Tarquinio Teles on 29/08/25.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @Bindable var vm: MapViewModel
    
    var body: some View {
        Map(initialPosition: vm.position, selection: $vm.selection) {
            ForEach(vm.searchResults, id: \.self) { result in
                Marker(item: result)
                    .mapItemDetailSelectionAccessory(.callout(.compact))
            }
        }
        .mapStyle(.standard(elevation: .realistic, showsTraffic: true))
        .safeAreaInset(edge: .bottom, content: { SearchView(vm: vm).padding(.horizontal) })
    }
}

#Preview {
    @Previewable let vm = MapViewModel()
    
    ContentView(vm: vm)
}
