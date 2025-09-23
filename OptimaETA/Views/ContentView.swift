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
        
    @State var showChart: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(position: $vm.position, selection: $vm.selection) {
                UserAnnotation()
                ShowAllRetrievedMarkers
                ShowRoutes
            }
            
            Overlay
        }
        .mapFeatureSelectionAccessory(.callout(.compact)
        )
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
        .sheet(isPresented: $showChart, content: { ETAChartView(vm: vm, isShowing: $showChart) })
    }

    private var ShowAllRetrievedMarkers: some MapContent {
        ForEach(Array(vm.searchResults.enumerated()), id: \.element) { (idx, result) in
            Marker(item: result)
                .mapItemDetailSelectionAccessory(.callout(.compact))
                .tag(MapSelection(idx))
        }
    }
    
    private var Overlay: some View {
        VStack {
            if vm.selection != nil {
                Button(action: {
                    showChart.toggle()
                },
                       label: {
                    Text("ETA")
                        .fontWeight(.bold)
                        .foregroundStyle(.primary.blendMode(.difference))
                        .padding()
                        .background(in: Circle())
                })
            } else {
                EmptyView()
            }
        }
        .padding()
    }
    
    private var ShowRoutes: some MapContent {
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

    private func time(for route: MKRoute) -> String {
        let timeInSeconds = route.expectedTravelTime
        
        return TimeIntervalFormatter.travelTime(for: timeInSeconds)
    }
    
    private func midPoint(for route: MKRoute) -> CLLocationCoordinate2D {
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
