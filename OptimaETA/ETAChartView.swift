//
//  ETAChartView.swift
//  OptimaETA
//
//  Created by Tarquinio Teles on 10/09/25.
//

import SwiftUI
import Charts

struct ETAChartView: View {
    let vm: MapViewModel
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    isShowing.toggle()
                }, label: {
                    Image(systemName: "x.circle.fill")
                        .foregroundStyle(.gray.opacity(0.7))
                })
            }
            .padding()
            .flipsForRightToLeftLayoutDirection(true)
            
            VStack(alignment: .leading) {
                if vm.etaSeries.isEmpty {
                    ProgressView()
                } else {
                    Text("Projected ETAs")
                        .font(.headline)
                    
                    Chart {
                        ForEach(vm.etaSeries, id: \.id) { eta in
                            BarMark(x: .value("Category", eta.label),
                                    yStart: .value("Value", eta.expectedDepartureTime),
                                    yEnd: .value("Value", eta.expectedArrivalTime)
                            )
                            .annotation(position: .top, content: {
                                Text(TimeIntervalFormatter.travelTime(for: eta.expectedTravelTime))
                                    .font(.caption)
                            })
                        }
                    }
                    .chartYScale(domain: .automatic(reversed: true))
                    .frame(height: 200)
                    .padding(.bottom, 30)
                    
                    Text("Expected Travel Time (min)")
                        .font(.headline)
                    Chart {
                        ForEach(vm.etaSeries, id: \.id) { eta in
                            LineMark(x: .value("Category", eta.label),
                                     y: .value("Value", eta.expectedTravelTime)
                            )
                            
                        }
                    }
                    .frame(height: 200)
                    
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
        .task {
            await vm.getETAs()
        }
    }
}

#Preview {
    @Previewable var vm = MapViewModel()
    ETAChartView(vm: vm, isShowing: .constant(true))
}
