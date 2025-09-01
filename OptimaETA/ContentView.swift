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
    var lm: CLLocationManager = CLLocationManager()
    
    var body: some View {
        Map(initialPosition: vm.position, selection: $vm.selection) {
            UserAnnotation()
            ForEach(Array(vm.searchResults.enumerated()), id: \.element) { (idx, result) in
                Marker(item: result)
                    .mapItemDetailSelectionAccessory(.callout(.compact))
                    .tag(MapSelection(idx))
            }
        }
        .mapFeatureSelectionAccessory(.callout(.compact))
        .mapControls {
            MapUserLocationButton()
        }
        .mapStyle(.standard(elevation: .realistic, showsTraffic: true))
        .safeAreaInset(edge: .bottom, content: { SearchView(vm: vm).padding(.horizontal) })
    }
}

#Preview {
    @Previewable let vm = MapViewModel()
    
    ContentView(vm: vm)
}
