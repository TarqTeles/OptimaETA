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
            
        }
        .mapStyle(.standard(elevation: .realistic, showsTraffic: true))
            
    }
}

#Preview {
    ContentView(vm: MapViewModel())
}
