//
//  Sample.swift
//  OptimaETA
//
//  Created by Tarquinio Teles on 02/09/25.
//

import Foundation
import MapKit

struct Sample {
    let baseURL = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
    
    func record<T: NSSecureCoding>(_ payload: [T], toFile name: String) throws {
        let data = try NSKeyedArchiver.archivedData(withRootObject: payload, requiringSecureCoding: true)
        let url = baseURL.appendingPathComponent(name)
        
        try data.write(to: url)
    }
    
    func retrieve<T: NSSecureCoding>(fromFile name: String) throws -> [T]? {
        let url = baseURL.appendingPathComponent(name)
        let data = try Data(contentsOf: url)
        
        return try NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClasses: [MKMapItem.self], from: data) as? [T]
    }
}

struct ATX {
    static let coordinate: CLLocationCoordinate2D = .init(latitude: +30.20219090, longitude: -97.66659810)
    static let marker = MKMapItem(placemark: .init(coordinate: coordinate))
    static let region = MKCoordinateRegion(center: coordinate,
                                           span: .init(
                                            latitudeDelta: 0.5,
                                            longitudeDelta: 0.5))
}
