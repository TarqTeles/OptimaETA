//
//  Sample.swift
//  OptimaETA
//
//  Created by Tarquinio Teles on 02/09/25.
//

import Foundation
import MapKit

struct ATX {
    static let coordinate: CLLocationCoordinate2D = .init(latitude: +30.20219090, longitude: -97.66659810)
    static let marker = MKMapItem(placemark: .init(coordinate: coordinate))
    static let region = MKCoordinateRegion(center: coordinate,
                                           span: .init(
                                            latitudeDelta: 0.5,
                                            longitudeDelta: 0.5))
}
