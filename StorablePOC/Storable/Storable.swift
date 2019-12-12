//
//  Storable.swift
//  StorablePOC
//
//  Created by Jp LaFond on 12/6/19.
//  Copyright © 2019 Jp LaFond. All rights reserved.
//

import Foundation

protocol Storable {
    func get<KeyType: Hashable, T: Codable>(key: KeyType) throws -> T?

    func set<KeyType: Hashable, T: Codable>(key: KeyType, value: T?) throws
}

extension Storable {
    func safeGet<KeyType: Hashable, T: Codable>(key: KeyType) -> T? {
        return try? get(key: key)
    }

    func safeSet<KeyType: Hashable, T: Codable>(key: KeyType, value: T?) {
        try? set(key: key, value: value)
    }

    /// Convert to data
    func asData<T: Codable>(_ input: T) -> Data? {
        let encoder = JSONEncoder()

        do {
            return try encoder.encode(input)
        }
        catch {
            print("\(self)::\(#function)[\(#line)] <\(error)>")
            return nil
        }
    }

    /// Convert from Data
    func fromData<T: Codable>(_ input: Data) -> T? {
        let decoder = JSONDecoder()

        do {
            return try decoder.decode(T.self, from: input)
        }
        catch {
            print("\(self)::\(#function)[\(#line)] <\(error)>")
            return nil
        }
    }
}
