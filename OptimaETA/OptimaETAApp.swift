//
//  OptimaETAApp.swift
//  OptimaETA
//
//  Created by Tarquinio Teles on 29/08/25.
//

import SwiftUI
import MapKit

@main
struct OptimaETAApp: App {
    let myVM = MapViewModel()
    let lm = CLLocationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView(vm: myVM, lm: lm)
                .onAppear {
                    if lm.authorizationStatus != .authorizedWhenInUse {
                        lm.requestWhenInUseAuthorization()
                    }
                }
        }
    }
}
