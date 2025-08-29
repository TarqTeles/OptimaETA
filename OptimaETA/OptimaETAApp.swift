//
//  OptimaETAApp.swift
//  OptimaETA
//
//  Created by Tarquinio Teles on 29/08/25.
//

import SwiftUI

@main
struct OptimaETAApp: App {
    let myVM = MapViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(vm: myVM)
        }
    }
}
