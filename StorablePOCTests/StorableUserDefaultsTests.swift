//
//  StorableUserDefaultsTests.swift
//  StorablePOCTests
//
//  Created by Jp LaFond on 12/6/19.
//  Copyright © 2019 Jp LaFond. All rights reserved.
//

import Foundation
import XCTest

@testable import StorablePOC

class StorableUserDefaultsTests: XCTestCase {
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

    let userDefaults = UserDefaults()

    let keys = Key.all

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        userDefaults.set(userDefaults.asData(true)!, forKey: Key.bool.rawValue)
        userDefaults.set(userDefaults.asData("test")!, forKey: Key.string.rawValue)
        userDefaults.set(userDefaults.asData(0xFADE)!, forKey: Key.int.rawValue)
        userDefaults.set(userDefaults.asData(Double(0xACE))!, forKey: Key.double.rawValue)
        userDefaults.set(userDefaults.asData("anyTest"), forKey: Key.key.rawValue)
    }

    override func tearDown() {
        keys.forEach { key in
            userDefaults.removeObject(forKey: key)
        }
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testUserDefaultsCases() {
        keys.forEach { key in
            guard let value = userDefaults.data(forKey: key) else {
                XCTFail("Unable to retrieve data for <\(key)>")
                return
            }

            switch key {
            case Key.bool.rawValue:
                guard let _ : Bool = userDefaults.fromData(value) else {
                    XCTFail("Unable to convert to bool for <\(key)>")
                    return
                }
            case Key.string.rawValue,
                 Key.key.rawValue:
                guard let _ : String = userDefaults.fromData(value) else {
                    XCTFail("Unable to convert to string for <\(key)>")
                    return
                }
            case Key.int.rawValue:
                guard let _ : Int = userDefaults.fromData(value) else {
                    XCTFail("Unable to convert to int for <\(key)>")
                    return
                }
            case Key.double.rawValue:
                guard let _ : Double = userDefaults.fromData(value) else {
                    XCTFail("Unable to convert to double for <\(key)>")
                    return
                }
            default:
                break
            }
            // Reset
            userDefaults.removeObject(forKey: key)
            // Negative
            XCTAssertNil(userDefaults.data(forKey: key))
        }
    }

    func testStorableGet() {
        do {
            try keys.forEach { key in
                switch key {
                case Key.bool.rawValue:
                    let boolValue: Bool? = try userDefaults.get(key: key)
                    XCTAssertNotNil(boolValue)
                case Key.string.rawValue:
                    let stringValue: String? = try userDefaults.get(key: key)
                    XCTAssertNotNil(stringValue)
                case Key.int.rawValue:
                    let intValue: Int? = try userDefaults.get(key: key)
                    XCTAssertNotNil(intValue)
                case Key.double.rawValue:
                    let doubleValue: Double? = try userDefaults.get(key: key)
                    XCTAssertNotNil(doubleValue)
                case Key.key.rawValue:
                    let stringValue: String? = try userDefaults.get(key: key)
                    let anyValue: Any = stringValue
                    XCTAssertNotNil(anyValue)
                default:
                    break
                }
            }
        }
        catch {
            print("\(error)")
        }
    }

    func test<K: Equatable,T>(key: K, value: T?) -> Bool where T: Codable, T: Equatable {
        do {
            guard let test: T = try userDefaults.get(key: key) else {
                print("\(#function)[\(#line)]<\(key)/\(value)> !get")
                return false
            }

            guard value == test else {
                print("\(#function)[\(#line)]<\(key)/\(value)> <\(test)!=\(value)>")
                return false
            }
            guard let keyString = key as? String else {
                print("\(#function)[\(#line)]<\(key)/\(value)> !String")
                return false
            }
            userDefaults.removeObject(forKey: keyString)
            guard userDefaults.object(forKey: keyString) == nil else {
                print("\(#function)[\(#line)]<\(key)/\(value)> !nil")
                return false
            }
            try userDefaults.set(key: key, value: value)

            guard let test2: T = try userDefaults.get(key: key) else {
                print("\(#function)[\(#line)]<\(key)/\(value)> nil @ SET")
                return false
            }

            return test2 == value
        } catch {
            print("\(error)<\(key)/\(value)>[\(#line)]")
            return false
        }
    }

    func testStorableSet() {
        XCTAssertFalse(test(key: 107, value: "Yes"))
        XCTAssertTrue(test(key: Key.bool.key, value: true))
        XCTAssertTrue(test(key: Key.string.key, value: "test"))
        XCTAssertFalse(test(key: Key.string.key, value: 0xFADE))
        XCTAssertTrue(test(key: Key.int.key, value: 0xFADE))
        XCTAssertTrue(test(key: Key.double.key, value: Double(0xACE)))
        XCTAssertFalse(test(key: Key.double.key, value: Double(0xACED)))
        tearDown()
        XCTAssertFalse(test(key: Key.string.key, value: "test"))
        try? userDefaults.set(key: Key.string.key, value: "test")
        XCTAssertTrue(test(key: Key.string.key, value: "test"))
        XCTAssertFalse(test(key: Key.string.key, value: Optional<String>(nil)))
        tearDown()
        XCTAssertFalse(test(key: Key.string.key, value: Optional<String>(nil)))

        do {
            try userDefaults.set(key: Key.string.key, value: Optional<String>(nil))
            XCTFail()
        }
        catch {
            print("\(error)")
        }
    }
}
