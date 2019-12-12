//
//  MockStorable.swift
//  StorablePOCTests
//
//  Created by Jp LaFond on 12/7/19.
//  Copyright © 2019 Jp LaFond. All rights reserved.
//

import Foundation
@testable import StorablePOC

class MockStorable {
    var values: [String: Codable] = [:]
}

extension MockStorable: Storable {
    func get<KeyType, T>(key: KeyType) throws -> T? where KeyType : Equatable, T : Decodable, T : Encodable {
        guard let keyString = key as? String else { return nil }
        return values[keyString] as? T
    }

    func set<KeyType, T>(key: KeyType, value: T?) throws where KeyType : Equatable, T : Decodable, T : Encodable {
        guard let keyString = key as? String else { return }
        values[keyString] = value
    }
}
