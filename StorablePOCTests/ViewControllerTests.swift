//
//  ViewControllerTests.swift
//  StorablePOCTests
//
//  Created by Jp LaFond on 12/11/19.
//  Copyright © 2019 Jp LaFond. All rights reserved.
//

import XCTest

@testable import StorablePOC

class ViewControllerTests: XCTestCase {

    var sut: ViewController!

    let keychain: Storable = StorableKeychain()
    let userDefaults: Storable = UserDefaults()

    override func setUp() {
        super.setUp()

        sut = ViewController()
    }

    override func tearDown() {
        sut = nil

        super.tearDown()
    }

    func testNonInjectedTest() {
        let keychainValue: String = keychain.safeGet(key: sut.key) ?? "Nothing set"
        let userDefaultsValue: String = userDefaults.safeGet(key: sut.key) ?? "Nothing set"

        XCTAssertEqual(keychainValue, sut.retrieve(sut.key, in: keychain))
        XCTAssertEqual(userDefaultsValue, sut.retrieve(sut.key, in: userDefaults))
    }

    func testInjectedTest() {
        let mockStorable: Storable = MockStorable()
        mockStorable.safeSet(key: sut.key, value: "test")

        sut.keychain = mockStorable
        sut.userDefaults = mockStorable

        XCTAssertEqual("test", sut.retrieve(sut.key, in: sut.keychain))
        XCTAssertEqual("test", sut.retrieve(sut.key, in: sut.userDefaults))

    }

}
