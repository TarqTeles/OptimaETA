//
//  SearchView.swift
//  OptimaETA
//
//  Created by Tarquinio Teles on 29/08/25.
//

import SwiftUI

struct SearchView: View {
    @Bindable var vm: MapViewModel
    
    var body: some View {
        TextField(text: $vm.searchString, label: { Label("Place of interest", systemImage: "magnifyingglass") })
            .textContentType(.location)
            .padding(.all)
            .foregroundStyle(.primary)
            .padding(.horizontal)
            .background(content: { RoundedRectangle(cornerRadius: 24).foregroundStyle(.thickMaterial) })
            .overlay {
                ExtractedView
            }
    }
    
    private var ExtractedView: some View {
        HStack {
            Spacer()
            Button(action: vm.clearSearchString, label: {
                Image(systemName: vm.isSearching ? "xmark.circle.fill" : "magnifyingglass")
            })
            .foregroundStyle(.secondary)
            .padding(.horizontal)
        }
    }
}

#Preview {
    @Previewable let vm = MapViewModel()

    SearchView(vm: MapViewModel())
        .frame(width: 400, height: 100)
}

