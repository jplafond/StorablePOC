//
//  StorableManagerTests.swift
//  StorablePOCTests
//
//  Created by Jp LaFond on 12/12/19.
//  Copyright © 2019 Jp LaFond. All rights reserved.
//

import XCTest
@testable import StorablePOC

class StorableManagerTests: XCTestCase {

    var sut: Storable!

    override func setUp() {
        super.setUp()

        sut = StorableManager.shared
    }

    override func tearDown() {
        // Setting the singleton back to actual so it's available for running normally after test.
        if let storableManager = sut as? StorableManager {
            storableManager.resetToActual()
        }
        sut = nil

        super.tearDown()
    }

    func testInjection() {
        let actualValue = sut.safeGet(key: StorableManager.Key.testCase) ?? ""

        let mockStorable: Storable = MockStorable()
        mockStorable.safeSet(key: StorableManager.Key.testCase.rawValue, value: "This is a test")

        guard let storableManager = sut as? StorableManager else {
            XCTFail("Not a storable manager")
            return
        }
        storableManager.inject(keychain: mockStorable, userDefaults: mockStorable)

        guard let valueToTest: String = sut.safeGet(key: StorableManager.Key.testCase) else {
            XCTFail("Unable to retrieve from mock")
            return
        }

        XCTAssertNotEqual(actualValue, valueToTest)
    }

    func testHasHadFirstRun() {
        // Actually testing against real value
        XCTAssertTrue((sut.safeGet(key: StorableManager.Key.firstRun) ?? false))
    }

    func testZZZHasHadFirstRun() {
        // Actually testing against real value (and ensured that it will run after the injection test)
        XCTAssertTrue((sut.safeGet(key: StorableManager.Key.firstRun) ?? false))
    }
}
