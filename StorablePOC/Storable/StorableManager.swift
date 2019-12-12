//
//  StorableManager.swift
//  StorablePOC
//
//  Created by Jp LaFond on 12/12/19.
//  Copyright © 2019 Jp LaFond. All rights reserved.
//

import Foundation

class StorableManager {
    enum Key: String {
        case firstRun
        case hasOnboarded
        case testCase
        case encryptionKey
        case lastSearchTerm
    }

    private enum StorageType {
        case keychain, userDefaults
    }

    private let keyType: [Key: StorageType] =
        [
            .firstRun: .userDefaults,
            .hasOnboarded: .userDefaults,
            .testCase: .keychain,
            .encryptionKey: .keychain,
            .lastSearchTerm: .userDefaults
        ]

    private (set) var keychain: Storable
    private (set) var userDefaults: Storable

    private static var sharedStorableManager: StorableManager = {
        let storableManager = StorableManager()

        return storableManager
    }()

    // This was defined as a singleton, but @MDias raised valid points on why this isn't a very good idea, so that we can parallelize our unit tests by continuing to have our defaults injected into various models/controllers, etc...
    class var shared: StorableManager {
        return sharedStorableManager
    }

    private init(keychain: Storable = StorableKeychain(),
                 userDefaults: Storable = UserDefaults()) {
        self.keychain = keychain
        self.userDefaults = userDefaults
    }
}

extension StorableManager: Storable {
    func get<KeyType, T>(key: KeyType) throws -> T? where KeyType : Hashable, T : Decodable, T : Encodable {
        guard let key = key as? Key,
            let storageType = keyType[key] else {
            throw StorableError.invalidKey
        }

        let storable: Storable

        switch storageType {
        case .keychain:
            storable = keychain
        case .userDefaults:
            storable = userDefaults
        }

        print("*Jp* \(#function) <\(key)/\(storageType)>(\(storable))")

        return try storable.get(key: key.rawValue)
    }

    func set<KeyType, T>(key: KeyType, value: T?) throws where KeyType : Hashable, T : Decodable, T : Encodable {
        guard let key = key as? Key,
            let storageType = keyType[key] else {
                throw StorableError.invalidKey
        }

        let storable: Storable

        switch storageType {
        case .keychain:
            storable = keychain
        case .userDefaults:
            storable = userDefaults
        }

        print("*Jp* \(#function) <\(key)/\(storageType)>(\(storable))")
        try storable.set(key: key.rawValue, value: value)
    }
}

extension StorableManager {
    func clearKeychainIfNotFirstRun() {
        let isFirstRun = safeGet(key: Key.firstRun) ?? false

        if !isFirstRun {
            guard let storableKeychain = keychain as? StorableKeychain else {
                print("Unit test")
                return
            }
            try? storableKeychain.deleteAll()
            try? set(key: Key.firstRun, value: true)
        }
    }

    var hasOnboarded: Bool {
        return safeGet(key: Key.hasOnboarded) ?? false
    }

    func inject(keychain: Storable, userDefaults: Storable) {
#if DEBUG
        self.keychain = keychain
        self.userDefaults = userDefaults
#endif
    }

    func resetToActual() {
#if DEBUG
        self.keychain = StorableKeychain()
        self.userDefaults = UserDefaults()
#endif
    }
}
