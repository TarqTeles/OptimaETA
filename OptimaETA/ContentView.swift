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
        Map(position: $vm.position, selection: $vm.selection) {
            UserAnnotation()
            ForEach(Array(vm.searchResults.enumerated()), id: \.element) { (idx, result) in
                Marker(item: result)
                    .mapItemDetailSelectionAccessory(.callout(.compact))
                    .tag(MapSelection(idx))
            }
            ForEach(vm.routes, id: \.self) { route in
                MapPolyline(route.polyline)
                    .stroke(.blue, lineWidth: 5)
                
                let center = midPoint(for: route)
                Annotation("", coordinate: center, anchor: .bottom) {
                    Text(time(for: route))
                        .font(.callout)
                        .foregroundStyle(.blue)
                        .background(Capsule().fill(.thinMaterial))
                }
            }
        }
        .mapFeatureSelectionAccessory(.callout(.compact)
        )
        .mapControls {
            MapUserLocationButton()
        }
        .mapStyle(.standard(elevation: .realistic, showsTraffic: true)
        )
        .safeAreaInset(edge: .bottom) { SearchView(vm: vm).padding(.horizontal)
        }
        .onChange(of: vm.searchResults) { _,_ in
            vm.selection = nil
            vm.position = .automatic
        }
        .onMapCameraChange { context in
            vm.visibleRegion = context.region
        }
    }
        
    func time(for route: MKRoute) -> String {
        let timeInSeconds = route.expectedTravelTime
        let date = Date(timeIntervalSinceNow: timeInSeconds)
        let df = DateFormatter()
        df.dateFormat = "mm:ss"
        
        return df.string(from: date)
    }
    
    func midPoint(for route: MKRoute) -> CLLocationCoordinate2D {
        let points = route.polyline.points()
        let pointCount = route.polyline.pointCount
        let buffer = UnsafeBufferPointer(start: points, count: pointCount)
        let myPoints = Array(buffer)
        let midPoint = myPoints[myPoints.count / 2]
        
        return midPoint.coordinate
    }

}

#Preview {
    @Previewable let vm = MapViewModel()
    
    ContentView(vm: vm)
}
