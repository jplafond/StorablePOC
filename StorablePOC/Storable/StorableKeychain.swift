//
//  StorableKeychain.swift
//  StorablePOC
//
//  Created by Jp LaFond on 12/6/19.
//  Copyright © 2019 Jp LaFond. All rights reserved.
//

import Foundation
import Security

struct StorableKeychain: Storable {
    private let service = "TestService"
    func get<KeyType: Hashable, T: Codable>(key: KeyType) throws -> T? {
        var result: AnyObject?

        let status = SecItemCopyMatching([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecAttrService: service,
            kSecReturnData: true
        ] as NSDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data,
                let resultReturn: T = fromData(data) else {
                    print("Unable to convert <\(key), \(result)>")
                return nil
            }
            return resultReturn
        case errSecItemNotFound:
            print("*Jp* \(#function)<\(key)> \(status)")
            return nil

        default:
            print("*Jp* \(#function)<\(key)> \(status)")
            throw status.description
        }
    }

    func set<KeyType, T>(key: KeyType, value: T?) throws where KeyType : Equatable , T: Codable {
        guard let valueData = asData(value) else {
            print("*Jp* \(#function)<\(key),\(value)>")
            throw StorableError.unableToSet
        }
        if try isPresent(key: key) {
            try update(key: key, value: valueData)
        } else {
            try add(key: key, value: valueData)
        }
    }

    func delete<K: Equatable>(key: K) throws {
        let status = SecItemDelete([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecAttrService: service
        ] as NSDictionary)
        guard status == errSecSuccess else { throw status.description }
    }

    func deleteAll() throws {
        let status = SecItemDelete([
            kSecClass: kSecClassGenericPassword
        ] as NSDictionary)
        guard status == errSecSuccess else { throw status.description }
    }
}

// Hat tip: http://www.splinter.com.au/2019/06/23/pure-swift-keychain/
extension String: Error { }

extension StorableKeychain {
    func isPresent<K: Equatable>(key: K) throws -> Bool {
        let status = SecItemCopyMatching([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecAttrService: service,
            kSecReturnData: false
        ] as NSDictionary, nil)
        switch status {
        case errSecSuccess:
            return true
        case errSecItemNotFound:
            return false
        default:
            print("*Jp* \(#function)<\(key)> \(status)")
            throw status.description
        }
    }

    private func add<K: Equatable>(key: K, value: Data) throws {
        let status = SecItemAdd([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecAttrService: service,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
            kSecValueData: value
        ] as NSDictionary, nil)
        guard status == errSecSuccess else {
            print("*Jp* \(#function)<\(key),\(value)> \(status)")
            throw status.description
        }
    }

    private func update<K: Equatable>(key: K, value: Data) throws {
        let status = SecItemUpdate([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecAttrService: service
        ] as NSDictionary, [
            kSecValueData: value
        ] as NSDictionary)
        guard status == errSecSuccess else {
            print("*Jp* \(#function)<\(key),\(value)> \(status)")
            throw status.description
        }
    }
}
