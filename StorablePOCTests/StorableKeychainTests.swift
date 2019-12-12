//
//  StorableKeychainTests.swift
//  StorablePOCTests
//
//  Created by Jp LaFond on 12/6/19.
//  Copyright © 2019 Jp LaFond. All rights reserved.
//

import Foundation
import XCTest

@testable import StorablePOC

class StorableKeychainTests: XCTestCase {
    enum Key: String {
        case bool, string, int, double, key

        static var all: [String] {
            [bool, string, int, double, key]
                .map { $0.rawValue }
        }

        var key: String {
            return self.rawValue
        }
    }

    let keychain = StorableKeychain()

    let keys = Key.all

    override func tearDown() {
        try? keychain.deleteAll()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func baseTest<T>(test: T) -> Bool where T: Codable, T: Equatable {
        guard let testData = keychain.asData(test) else {
            XCTFail("Unable to convert: \(test)")
            return false
        }
        guard let result: T = keychain.fromData(testData) else {
            XCTFail("Unable to revert from: <\(testData)/\(test)>")
            return false
        }
        return result == test
    }

    func testBase() {
        XCTAssertTrue(baseTest(test: true))
        XCTAssertTrue(baseTest(test: "test"))
        XCTAssertTrue(baseTest(test: 0xFADE))
        XCTAssertTrue(baseTest(test: Double(0xACE)))

        XCTAssertTrue(baseTest(test: ["test"]))
    }

    func testSetGetDelGet<K: Hashable, T>(key: K, value: T) -> Bool where T: Codable, T: Equatable {
        do {
            guard try false == keychain.isPresent(key: key) else {
                XCTFail("\(key) unexpectably present")
                return false
            }
            try keychain.set(key: key, value: value)
            guard let sut: T = try keychain.get(key: key) else {
                XCTFail("Unable to convert for \(key)/\(value)")
                return false
            }
            guard sut == value else {
                XCTFail("\(sut) != \(value)")
                return false
            }
            try keychain.delete(key: key)

            guard try false == keychain.isPresent(key: key) else {
                XCTFail("\(key) present after delete")
                return false
            }

            let result: T? = try keychain.get(key: key)

            return nil == result
        }
        catch {
            XCTFail("Unable to test <\(error)>")
            return false
        }
    }

    func testStorageSet() {
        XCTAssertTrue(testSetGetDelGet(key: 107, value: 107))
        XCTAssertTrue(testSetGetDelGet(key: Key.bool.key, value: true))
        XCTAssertTrue(testSetGetDelGet(key: Key.string.key, value: "test"))
        XCTAssertTrue(testSetGetDelGet(key: Key.int.key, value: 0xFADE))
        XCTAssertTrue(testSetGetDelGet(key: Key.double.key, value: Double(0xACE)))
    }
}
