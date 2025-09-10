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
            if vm.etaSeries.isEmpty {
                ProgressView()
            } else {
                Chart {
                    ForEach(vm.etaSeries, id: \.id) { eta in
                        BarMark(x: .value("Category", eta.label),
                                 yStart: .value("Value", eta.expectedDepartureTime),
                                yEnd: .value("Value", eta.expectedArrivalTime)
                        )
                        
                    }
                }
                .chartYScale(domain: .automatic(reversed: true))
                .frame(height: 300)
                .padding(.horizontal, 30)
            }
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
