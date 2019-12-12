//
//  UserDefaulsExtension.swift
//  StorablePOC
//
//  Created by Jp LaFond on 12/6/19.
//  Copyright © 2019 Jp LaFond. All rights reserved.
//

import Foundation

extension UserDefaults: Storable {
    // MARK: Storable Conformance
    func get<KeyType, T: Codable>(key: KeyType) throws -> T? where KeyType : Equatable {
        guard let keyString = key as? String else {
            throw StorableError.invalidKey
        }

        guard let data = data(forKey: keyString) else {
            print("*Jp* Unable to get <\(keyString)/\(self.data(forKey: keyString))>")
            return nil
        }

        return fromData(data)
    }

    func set<KeyType, T: Codable>(key: KeyType, value: T?) throws where KeyType : Equatable {
        guard let keyString = key as? String else {
            throw StorableError.invalidKey
        }

        guard value != nil,
            let data = asData(value) else {
                print ("*Jp* Unable to set <\(key):\(value)>")
                throw StorableError.unableToSet
        }

        print("*Jp* data[\(data)]>")

        if let actual: T = fromData(data) {
            print("*Jp* actual <\(actual)>")
        } else {
            print("*Jp* actual nil")
        }

        set(data, forKey: keyString)

        guard let dataToCheck: Data = self.data(forKey: keyString) else {
            print("*Jp* unable to return data for <\(keyString)>")
            return
        }
        guard let resultToCheck: T = fromData(dataToCheck) else {
            print("*Jp* unable to convert from data <\(dataToCheck)>")
            return
        }

        print("\(resultToCheck) vs \(value)")
    }
}
