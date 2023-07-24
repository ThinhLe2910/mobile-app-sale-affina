//
//  Parsable.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 24/05/2022.
//

import Foundation

// For easily decode
protocol Parsable: Decodable {
    init(dict: [String: Any]) throws
}

extension Parsable {
    init(dict: [String: Any]) throws {
        let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
        let decoder = JSONDecoder()
        self = try decoder.decode(Self.self, from: jsonData)
    }
}
