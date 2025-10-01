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
        try save(data, toFile: name)
    }
    
    func record<T: Codable>(_ payload: [T], toFile name: String) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        let data = try encoder.encode(payload)
        try save(data, toFile: name)
    }

    func retrieve<T: NSSecureCoding>(fromFile name: String) throws -> [T]? {
        let data = try read(fromFile: name)
        
        return try NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClasses: [MKMapItem.self], from: data) as? [T]
    }

    func retrieve<T: Codable>(fromFile name: String) throws -> [T] {
        let data = try read(fromFile: name)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode([T].self, from: data)
    }
    
    private func save(_ data: Data, toFile name: String) throws {
        let url = baseURL.appendingPathComponent(name)
        
        try data.write(to: url)
    }
    
    private func read(fromFile name: String) throws -> Data {
        let url = baseURL.appendingPathComponent(name)
        return try Data(contentsOf: url)
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
