//
//  MockStorableTests.swift
//  StorablePOCTests
//
//  Created by Jp LaFond on 12/7/19.
//  Copyright © 2019 Jp LaFond. All rights reserved.
//

import XCTest

class MockStorableTests: XCTestCase {

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

    let keys = Key.all
    let mockStorable = MockStorable()

    func testGetSet() {
        XCTAssertFalse(testGetSet(key: 107, value: 107))
        XCTAssertTrue(testGetSet(key: Key.bool.key, value: true))
        XCTAssertTrue(testGetSet(key: Key.string.key, value: "test"))
        XCTAssertTrue(testGetSet(key: Key.int.key, value: 0xFADE))
        XCTAssertTrue(testGetSet(key: Key.double.key, value: Double(0xACE)))
    }

    func testGetSet<K: Equatable, V: Codable>(key: K, value: V) -> Bool where V: Equatable {
        do {
            if let initialValue: V = try mockStorable.get(key: key) {
                print("\(key)/\(initialValue) unexpectedly present")
                return false
            }
            try mockStorable.set(key: key, value: value)
            guard let toTest: V = try mockStorable.get(key: key) else {
                print("\(key) not present after set")
                return false
            }
            return toTest == value
        }
        catch {
            print("\(error) for <\(key)/\(value)>")
            return false
        }
    }

}
