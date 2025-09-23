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
    
    @State var desiredETA: Date = Date()
    
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
                DatePicker("Desired ETA", selection: $desiredETA, displayedComponents: .hourAndMinute)
                    .font(.headline)
            
                if vm.etaSeries.isEmpty {
                    Spacer()
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    Spacer()
                } else {
                    Text("Projected ETAs")
                        .font(.headline)
                    
                    Chart {
                        RuleMark(y: .value("Value", desiredETA))
                            .annotation(position: .topLeading) {
                                Text("Desired ETA: \(desiredETA.formatted(date: .omitted, time: .shortened))")
                                    .font(.caption)
                                    .offset(x: 110.0)
                            }
                        
                        ForEach(vm.etaSeries, id: \.id) { eta in
                            let diff = eta.expectedTravelTime - vm.fastestTravelTime
                            BarMark(x: .value("Category", eta.label),
                                    yStart: .value("Value", eta.expectedDepartureTime),
                                    yEnd: .value("Value", eta.expectedArrivalTime)
                            )
                            .cornerRadius(10.0, style: .continuous)
                            .annotation(position: .top) {
                                if diff > 60.0 {
                                    Text("+\(TimeIntervalFormatter.travelTime(for: Double(Int(diff / 60.0)) * 60.0))")
                                        .font(.caption)
                                        .fontWeight(.thin)
                                }
                            }
                            .opacity(diff < 60.0 ? 0.8 : 0.5)
                            .foregroundStyle(eta.expectedArrivalTime > desiredETA ? .red : .blue)
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
            desiredETA = vm.earliestETA.addingTimeInterval(halfHour)
        }
    }
    
    private let halfHour: TimeInterval = 30 * 60.0
}

#Preview {
    @Previewable var vm = MapViewModel()
    ETAChartView(vm: vm, isShowing: .constant(true))
}
